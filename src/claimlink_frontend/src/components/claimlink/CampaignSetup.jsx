import React, { useState } from "react";
import { CiImageOn } from "react-icons/ci";
import { CiWallet } from "react-icons/ci";
import Summary from "./Summary";
import Stepper from "../../common/Stepper";
import { Link } from "react-router-dom";

const CampaignSetup = () => {
  const [currentStep, setCurrentStep] = useState(1);

  const handleNext = () => {
    setCurrentStep((prev) => Math.min(prev + 1, 4)); // Assuming there are 4 steps
  };

  const handleBack = () => {
    setCurrentStep((prev) => Math.max(prev - 1, 1));
  };
  return (
    <>
      <Stepper currentStep={currentStep} />
      <div className="flex justify-between">
        <div className="h-screen  sm:w-[70%] w-screen space-y-6 p-6 ">
          <p className="text-2xl text-gray-900 font-semibold">campaign setup</p>

          <div className="space-y-3">
            <p className="text-gray-900 font-semibold">Title</p>
            <input
              type="text"
              className="sm:w-[75%] w-full h-10 rounded border-2 px-3 border-gray-100"
              placeholder="Text "
            />
          </div>
          <div className="sm:w-[75%] w-full space-y-3">
            <p className="text-gray-900 font-semibold">contract</p>
            <div className="sm:flex sm:gap-4 ">
              <div className="sm:w-[50%] rounded-md mb-4 sm:mb-0 h-36 border-2 border-gray-100 space-y-6 p-4 bg-white ">
                <CiImageOn size={36} className="text-[#5542F6]" />
                <div>
                  <p className="font-semibold"> NFTs </p>
                  <p className="text-sm text-gray-500">DIP-721/ICRC-7</p>
                </div>
              </div>
              <div className="sm:w-[50%] rounded-md h-36 border-2 border-gray-100 space-y-6 p-4 bg-white">
                <CiWallet size={36} className="text-[#5542F6]" />
                <div>
                  <p className="font-semibold"> Tokens</p>
                  <p className="text-sm text-gray-500">ERC 20</p>
                </div>
              </div>
            </div>
          </div>
          <div className="space-y-3 sm:w-[75%] w-full">
            <p className="text-gray-900 font-semibold">Choose collection</p>
            <input
              type="text"
              className=" w-full h-10 rounded border-2 px-3 border-gray-100"
              placeholder="Text "
            />
            <p className="flex items-center sm:w-1/4 w-1/3  justify-center text-gray-500 font-semibold text-xs   rounded-3xl bg-gray-200 px-3 py-1">
              My last collection
            </p>
          </div>

          <button
            className="px-4 py-3 sm:w-[18%] w-full bg-[#5542F6]  text-xs font-quicksand  rounded transition  duration-200 hover:bg-blue-600 text-white"
            onClick={handleNext}
            disabled={currentStep === 4}
          >
            <Link to="/claim-pattern">Next</Link>
          </button>
        </div>
        <Summary />
      </div>
    </>
  );
};

export default CampaignSetup;
