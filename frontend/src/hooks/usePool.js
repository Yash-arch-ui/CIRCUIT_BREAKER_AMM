import { useSuiClient } from "@mysten/dapp-kit";
import { POOL_ID } from "../utils/constants";
import { useQuery } from "@tanstack/react-query";

export function usePool() {
  const client = useSuiClient();

  return useQuery({
    queryKey: ['pool', POOL_ID],
    queryFn: async () => {
      const obj = await client.getObject({
        id: POOL_ID,
        options: { showContent: true },
      });

      if (!obj.data || !obj.data.content || obj.data.content.dataType !== 'moveObject') {
        throw new Error("Failed to fetch pool object content or object is not a Move Object");
      }
      const fields = obj.data.content.fields;

      const resX = Number(fields.reserve_x || 0);
      const resY = Number(fields.reserve_y || 0);
      const computedSpotPrice = resX > 0 ? resY / resX : 0;

      return {
        reserveX:   BigInt(fields.reserve_x ?? 0),
        reserveY:   BigInt(fields.reserve_y ?? 0),
        spotPrice:  computedSpotPrice,
        twap:       BigInt(fields.last_price_cumulative ?? 0),
        paused:     !!fields.paused,
        cooldown:   Number(fields.last_swap_timestamp ?? 0),
        lpSupply:   BigInt(fields.lp_supply?.fields?.value ?? 0),
      };
    },
    refetchInterval: 5000, 
  });
}