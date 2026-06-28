import { useSignAndExecuteTransaction } from "@mysten/dapp-kit";
import { useQueryClient } from "@tanstack/react-query";
import { buildSwapTx } from "../utils/transactions";

export function useSwap() {
  const { mutate: signAndExecute, isPending } = useSignAndExecuteTransaction();
  const queryClient = useQueryClient();

  const swap = ({ coinObjectId, amountIn, minAmountOut, isXtoY, onSuccess }) => {
    // 1. Build the programmable transaction block (PTB)
    const tx = buildSwapTx({ coinObjectId, amountIn, minAmountOut, isXtoY });

    // 2. Pass EVERYTHING inside a single configuration object
    signAndExecute(
      {
        transaction: tx,
        // Callbacks belong inside this first object wrapper
        onSuccess: (result) => {
          console.log('Swap digest:', result.digest);
          
          // Invalidate pool cache → immediately triggers a UI refetch across your Bento cards
          queryClient.invalidateQueries({ queryKey: ['pool'] });
          
          // Execute optional custom callback if passed from the component
          onSuccess?.(result);
        },
        onError: (err) => {
          console.error('Swap execution failed:', err);
        },
      }
    );
  };

  return { swap, isPending };
}