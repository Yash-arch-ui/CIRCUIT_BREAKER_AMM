// src/hooks/useAddLiquidity.js
import { useSignAndExecuteTransaction } from '@mysten/dapp-kit';
import { useQueryClient } from '@tanstack/react-query';
import { buildAddLiquidityTx } from '../utils/transactions';

export function useAddLiquidity() {
  const { mutate: signAndExecute, isPending } = useSignAndExecuteTransaction();
  const queryClient = useQueryClient();

  const addLiquidity = ({ coinXObjectId, coinYObjectId, amountX, amountY, onSuccess }) => {
    const tx = buildAddLiquidityTx({ coinXObjectId, coinYObjectId, amountX, amountY });

    signAndExecute(
      { transaction: tx },
      {
        onSuccess: (result) => {
          console.log('Liquidity Provision Digest:', result.digest);
          
          queryClient.invalidateQueries({ queryKey: ['pool'] });
          onSuccess?.(result);
        },
        onError: (err) => {
          console.error('Failed to add liquidity:', err);
        },
      }
    );
  };

  return { addLiquidity, isPending };
}