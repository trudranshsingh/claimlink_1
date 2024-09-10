import React, { useState } from "react";
import { Switch } from "@headlessui/react";
import { motion } from "framer-motion";
import { TbInfoHexagon } from "react-icons/tb";
import Summary from "./Summary";
import MainButton, { BackButton } from "../../common/Buttons";
import { useAuth } from "../../connect/useClient";
import { Principal } from "@dfinity/principal";
import toast from "react-hot-toast";
const Launch = ({ handleNext, handleBack, formData, setFormData }) => {
  const [errors, setErrors] = useState({});
  const [loading, setLoading] = useState(false);
  const { backend, principal } = useAuth();
  const [time, setTime] = useState(0);
  const liveUrl =
    process.env.REACT_APP_LIVE_URL || import.meta.env.VITE_LIVE_URL;
  console.log("Live URL:", liveUrl);

  const url = process.env.PROD
    ? `https://${process.env.CANISTER_ID_CLAIMLINK_BACKEND}.icp0.io`
    : "http://localhost:3000";
  const validateForm = () => {
    const newErrors = {};

    if (
      !formData.walletOptions.internetIdentity &&
      !formData.walletOptions.plugWallet &&
      !formData.walletOptions.other
    ) {
      newErrors.walletOptions = "Please select at least one wallet option.";
    }

    if (formData.enabled && !formData.expirationDate) {
      newErrors.expirationDate = "Please select an expiration date.";
    }

    if (formData.includeICP && !formData.icpAmount) {
      newErrors.icpAmount = "Please specify the amount of ICP.";
    }

    setErrors(newErrors);

    return Object.keys(newErrors).length === 0;
  };

  const handleWalletOptionChange = (option) => {
    setFormData({
      ...formData,
      walletOptions: {
        ...formData.walletOptions,
        [option]: !formData.walletOptions[option],
      },
    });
  };

  const handleIncludeICPChange = (include) => {
    setFormData({ ...formData, includeICP: include });
  };

  const handleCreate = async (e) => {
    e.preventDefault();
    console.log("Starting campaign creation");

    if (!backend) {
      toast.error("Backend actor not initialized");
      return;
    }

    if (!validateForm()) {
      return;
    }
    setLoading(true);
    try {
      console.log("Form data:", formData);
      console.log("Principal:", principal.toText());

      const collectionPrincipal = Principal.fromText(formData.collection);

      const tokenIds = formData.tokenIds.map((token) => {
        const id = Number(token);
        if (isNaN(id) || id < 0 || id > 4294967295) {
          throw new Error(`Invalid token ID: ${token}`);
        }
        return id;
      });

      const selectedWalletOptions = Object.keys(formData.walletOptions)
        .filter((option) => formData.walletOptions[option])
        .map((option) => {
          switch (option) {
            case "internetIdentity":
              return "internetidentity";
            case "plugWallet":
              return "plug";
            case "other":
              return "other";
            default:
              return option;
          }
        });

      const paddedHour = formData.hour.padStart(2, "0");
      const paddedMinute = formData.minute.padStart(2, "0");

      const dateString = `${formData.expirationDate}T${paddedHour}:${paddedMinute}:00Z`;
      const date = new Date(dateString);

      if (isNaN(date.getTime())) {
        console.error("Invalid Date generated:", dateString);
      } else {
        const timestampMillis = date.getTime();
        setTime(timestampMillis);
        console.log("Valid time:", date, "Timestamp:", timestampMillis);
      }

      const res = await backend?.createCampaign(
        formData.title,
        formData.tokenType,
        collectionPrincipal,
        formData.pattern,
        tokenIds,
        formData.walletOption,
        selectedWalletOptions,
        time
      );

      if (res) {
        if (res[1]?.[0] !== -1 && res[1]?.[0] !== undefined) {
          const claimLink = `${url}/linkclaiming/${formData.collection}/${res[1]?.[0]}`;
          console.log("Link created successfully:", claimLink);
        }
        console.log("Campaign created successfully:", res);
        toast.success("Campaign created successfully!");
        handleNext();
      } else {
        console.log("Failed to create campaign, no response received");
        toast.error("Failed to create campaign");
      }
    } catch (error) {
      console.error("Error creating campaign:", error);
      toast.error(`Error creating campaign: ${error.message}`);
    } finally {
      setLoading(false);
    }
  };

  const pageVariants = {
    initial: { opacity: 0, x: "-100vw" },
    in: { opacity: 1, x: 0 },
    out: { opacity: 0, x: "100vw" },
  };

  const pageTransition = { type: "tween", ease: "anticipate", duration: 0.8 };

  const getCurrentDateTime = () => {
    const now = new Date();
    const dateStr = now.toISOString().slice(0, 10);
    const hour = now.getUTCHours();
    const minute = now.getUTCMinutes();
    return { dateStr, hour, minute };
  };

  const { dateStr, hour, minute } = getCurrentDateTime();

  return (
    <motion.div
      initial="initial"
      animate="in"
      exit="out"
      variants={pageVariants}
      transition={pageTransition}
      className="flex justify-between"
    >
      <div className="pl-4 py-4 sm:w-[70%] space-y-6">
        <h1 className="text-3xl font-semibold">Wallet Option</h1>
        <div>
          <p className="font-semibold text-sm text-gray-400 my-4">
            Select the wallet that will be highlighted as "recommended"
          </p>
          <div className="mt-2 flex flex-col space-y-4">
            <label className="inline-flex items-center">
              <input
                type="radio"
                name="wallet"
                checked={formData.walletOptions.internetIdentity}
                onChange={() => handleWalletOptionChange("internetIdentity")}
                className="form-radio"
                style={{ backgroundColor: "#5542F6" }}
              />
              <span className="ml-2">Internet Identity</span>
            </label>
            <label className="inline-flex items-center">
              <input
                type="radio"
                name="wallet"
                disabled={loading}
                checked={formData.walletOptions.plugWallet}
                onChange={() => handleWalletOptionChange("plugWallet")}
                className="form-radio"
              />
              <span className="ml-2">Plug Wallet</span>
            </label>
            <label className="inline-flex items-center">
              <input
                type="radio"
                disabled={loading}
                name="wallet"
                checked={formData.walletOptions.other}
                onChange={() => handleWalletOptionChange("other")}
                className="form-radio"
              />
              <span className="ml-2">Other</span>
            </label>
          </div>
          {errors.walletOptions && (
            <p className="text-red-500 text-sm mt-1">{errors.walletOptions}</p>
          )}
        </div>

        <div className="bg-gray-400 sm:w-[75%] my-8 border border-gray-300/2"></div>

        <div>
          <div className="flex items-center justify-between sm:w-[75%]">
            <p className="font-semibold text-lg">Link Expiration</p>
            <Switch
              disabled={loading}
              checked={formData.enabled}
              onChange={(enabled) =>
                setFormData({
                  ...formData,
                  enabled,
                  expirationDate: enabled ? dateStr : "",
                  hour: enabled ? hour : "",
                  minute: enabled ? minute : "",
                })
              }
              className="group inline-flex h-6 w-12 items-center rounded-full bg-gray-200 transition"
            >
              <span className="size-4 translate-x-1 rounded-full bg-[#5542F6] transition group-data-[checked]:translate-x-7" />
            </Switch>
          </div>
          <p className="font-semibold text-sm text-gray-400 my-4">
            You can set up the link expiration, so that users will not be able
            to claim after a certain day and time
          </p>
          {formData.enabled && (
            <div className="mt-6 space-y-4 sm:w-[75%]">
              <h1 className="text-lg font-semibold">Expiration Date</h1>
              <div className="flex md:flex-row flex-col w-full justify-between gap-4">
                <input
                  type="date"
                  disabled={loading}
                  name="expirationDate"
                  id="expirationDate"
                  className="bg-white px-2 py-2 outline-none border border-gray-200 sm:w-[73%] w-full rounded-md"
                  value={formData.expirationDate}
                  min={dateStr}
                  onChange={(e) =>
                    setFormData({ ...formData, expirationDate: e.target.value })
                  }
                />
                <div className="flex md:justify-normal justify-between gap-4">
                  <select
                    name="startHour"
                    disabled={loading}
                    id="startHour"
                    className="bg-white w-full px-2 py-2 outline-none border border-gray-200 rounded-md"
                    value={formData.hour}
                    onChange={(e) =>
                      setFormData({ ...formData, hour: e.target.value })
                    }
                  >
                    {Array.from({ length: 24 }, (_, i) => i).map((hr) => (
                      <option key={hr} value={hr}>
                        {hr}
                      </option>
                    ))}
                  </select>
                  <select
                    name="startMinute"
                    id="startMinute"
                    disabled={loading}
                    className="bg-white w-full px-2 py-2 outline-none border border-gray-200 rounded-md"
                    value={formData.minute}
                    onChange={(e) =>
                      setFormData({ ...formData, minute: e.target.value })
                    }
                  >
                    {Array.from({ length: 60 }, (_, i) => i).map((min) => (
                      <option key={min} value={min}>
                        {min}
                      </option>
                    ))}
                  </select>
                </div>
              </div>
              {errors.expirationDate && (
                <p className="text-red-500 text-sm mt-1">
                  {errors.expirationDate}
                </p>
              )}
            </div>
          )}
        </div>

        <div className="bg-gray-400 sm:w-[75%] my-8 border border-gray-300/2"></div>

        <div>
          <div className="flex items-center justify-between sm:w-[75%]">
            <p className="font-semibold text-lg">Include ICP</p>
            <Switch
              disabled={loading}
              checked={formData.includeICP}
              onChange={(include) => handleIncludeICPChange(include)}
              className="group inline-flex h-6 w-12 items-center rounded-full bg-gray-200 transition"
            >
              <span className="size-4 translate-x-1 rounded-full bg-[#5542F6] transition group-data-[checked]:translate-x-7" />
            </Switch>
          </div>
          <p className="font-semibold text-sm text-gray-400 my-4">
            Include ICP in the link for users to claim
          </p>
          {formData.includeICP && (
            <div className="mt-6 space-y-4 sm:w-[75%]">
              <h1 className="text-lg font-semibold">Amount of ICP</h1>
              <div className="flex flex-col w-full justify-between gap-4">
                <input
                  type="number"
                  disabled={loading}
                  name="icpAmount"
                  id="icpAmount"
                  className="bg-white px-2 py-2 outline-none border border-gray-200 sm:w-[50%] w-full rounded-md"
                  value={formData.icpAmount}
                  onChange={(e) =>
                    setFormData({ ...formData, icpAmount: e.target.value })
                  }
                  placeholder="0.0"
                />
              </div>
              {errors.icpAmount && (
                <p className="text-red-500 text-sm mt-1">{errors.icpAmount}</p>
              )}
            </div>
          )}
        </div>

        <div className="bg-gray-400 sm:w-[75%] my-8 border border-gray-300/2"></div>

        <div className="flex items-center sm:w-[75%]">
          <TbInfoHexagon className="mr-4 text-2xl" />
          <p className="font-semibold text-sm text-gray-400 my-4">
            The users will receive an NFT with a valid link after successful
            claim
          </p>
        </div>

        <div className="bg-gray-400 sm:w-[75%] my-8 border border-gray-300/2"></div>

        <div className="flex justify-between items-center">
          <BackButton
            onClick={handleBack}
            text={"back"}
            loading={loading}
          ></BackButton>
          <MainButton
            onClick={handleCreate}
            text={"submit"}
            loading={loading}
          ></MainButton>
        </div>
      </div>
      <div className="p-6 flex items-center w-[30%] sm:block hidden">
        <Summary formData={formData} />
      </div>
    </motion.div>
  );
};

export default Launch;
