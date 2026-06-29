import { useSignAndExecuteTransaction } from '@mysten/dapp-kit';
import { useQueryClient } from '@tanstack/react-query';
import { buildRemoveLiquidityTx } from '../utils/transactions';

export function useRemoveLiquidity() {
  const { mutate: signAndExecute, isPending } = useSignAndExecuteTransaction();
  const queryClient = useQueryClient();

  const removeLiquidity = ({ lpCoinObjectId, lpAmount, onSuccess }) => {
    const tx = buildRemoveLiquidityTx({ lpCoinObjectId, lpAmount });

    signAndExecute(
      { transaction: tx },
      {
        onSuccess: (result) => {
          console.log('Liquidity Burn Digest:', result.digest);
          queryClient.invalidateQueries({ queryKey: ['pool'] });
          onSuccess?.(result);
        },
        onError: (err) => {
          console.error('Failed to remove liquidity:', err);
        },
      }
    );
  };

  return { removeLiquidity, isPending };
}