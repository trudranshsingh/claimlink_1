import React, { useEffect, useState } from "react";
import { motion } from "framer-motion";
import { useAuth } from "../connect/useClient";
import { useNavigate } from "react-router-dom";

const CollectionCard = ({ data }) => {
  const [copy, setCopy] = useState(0);
  const { backend } = useAuth();
  const [loader, setLoader] = useState(true);
  const navigate = useNavigate();
  const getNonfungibleTokensNft = async () => {
    try {
      setLoader(true);

      const res = await backend.getNonFungibleTokens(data[1]);
      const res1 = await backend.getStoredTokens(data[1]);
      setCopy(res.length + res1.length);
      console.log(res.length + res1.length, "hello sun ");

      console.log(res);
    } catch (error) {
      console.log("Error getting nfts length ", error);
    } finally {
      setLoader(false);
    }
  };
  useEffect(() => {
    getNonfungibleTokensNft();
  }, [backend]);

  return (
    <motion.div
      initial={{ opacity: 0, scale: 0 }}
      animate={{ opacity: 1, scale: 1 }}
      transition={{ duration: 1 }}
      className="bg-white px-4 py-4 rounded-xl flex flex-col cursor-pointer"
      onClick={() => {
        navigate(`/minter/${data[1]?.toText()}/token-home`);
      }}
    >
      <div className="flex justify-start  space-x-4">
        <img
          src={data[4]}
          alt="Campaign"
          className="w-12 h-12 object-cover rounded-md"
          style={{
            border: "2px solid white",
            zIndex: 3,
          }}
        />
        <img
          src="https://via.placeholder.com/100"
          alt="Campaign"
          className="w-12 h-12 object-cover rounded-md"
          style={{
            border: "2px solid white",
            zIndex: 2,
            marginLeft: -24,
          }}
        />
        <img
          src="https://via.placeholder.com/100"
          alt="Campaign"
          className="w-12 h-12 object-cover rounded-md"
          style={{
            border: "2px solid white",
            zIndex: 1,
            marginLeft: -24,
          }}
        />
      </div>
      <h2 className="text-lg  font-semibold text-[#2E2C34] mt-3 ">{data[2]}</h2>
      {/* <p className="text-xs text-[#84818A] mt-1 ">
      {formatTimestamp(data[0])}
    </p> */}
      <div className="border border-gray-300 my-4 w-full"></div>
      <div className="mt-2 w-full">
        <div className="flex justify-between">
          <p className="text-xs text-[#84818A] ">Address</p>
          <p className="text-[#564BF1] text-xs line-clamp-1 w-24 font-semibold">
            {data[1]?.toText()}
          </p>
        </div>
        <div className="flex justify-between mt-2">
          <p className="text-xs text-[#84818A] ">All token copies</p>
          <p className="text-[#2E2C34] text-xs font-semibold">{copy}</p>
        </div>
        <div className="flex justify-between mt-2">
          <p className="text-xs text-[#84818A] ">Token standard</p>
          <p className="text-[#2E2C34] text-xs  font-semibold">EXT</p>
        </div>
      </div>
    </motion.div>
  );
};

export default CollectionCard;
