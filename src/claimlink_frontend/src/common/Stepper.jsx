import React from "react";

const steps = [
  { id: 1, name: "Campaign setup" },
  { id: 2, name: "Claim pattern" },
  { id: 3, name: "Distribution" },
  { id: 4, name: "Launch" },
];

const Stepper = ({ currentStep }) => {
  return (
    <div className="hidden sm:block">
      <div className="flex h-12  px-6 bg-[#FBFAFC] text-gray-600 border-b border-gray-300">
        {steps.map((step, index) => (
          <div key={step.id} className="flex items-center">
            <div
              className={`flex items-center justify-center px-2 border-b-2 h-full ${
                step.id < currentStep
                  ? "border-green-400 text-white"
                  : step.id === currentStep
                  ? "border-blue-500 text-white"
                  : "text-gray-500"
              }`}
            >
              <div
                className={`rounded-full p-[1px] border-2 ${
                  step.id < currentStep
                    ? "border-green-400 text-white"
                    : step.id === currentStep
                    ? "border-blue-500 text-white"
                    : "border-gray-300 text-gray-500"
                }`}
              >
                <div
                  className={`w-5 h-5 rounded-full flex items-center justify-center ${
                    step.id < currentStep
                      ? "bg-green-500 text-white"
                      : step.id === currentStep
                      ? "bg-blue-500 text-white"
                      : "bg-gray-300 text-gray-500"
                  }`}
                >
                  {step.id < currentStep ? (
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      className="h-5 w-5"
                      viewBox="0 0 20 20"
                      fill="currentColor"
                    >
                      <path
                        fillRule="evenodd"
                        d="M16.707 5.293a1 1 0 00-1.414 0L8 12.586 4.707 9.293a1 1 0 00-1.414 1.414l4 4a1 1 0 001.414 0l8-8a1 1 0 000-1.414z"
                        clipRule="evenodd"
                      />
                    </svg>
                  ) : (
                    <span className="font-semibold text-sm text-white">
                      {step.id}
                    </span>
                  )}
                </div>
              </div>
              <div className="ml-2 text-xs text-center">
                <span
                  className={`${
                    step.id < currentStep
                      ? "text-green-500"
                      : step.id === currentStep
                      ? "text-blue-500"
                      : "text-gray-500"
                  }`}
                >
                  {step.name}
                </span>
              </div>
            </div>
            {index !== steps.length - 1 && (
              <div
                className={`flex-1 border-t-2 ${
                  step.id < currentStep
                    ? "border-green-500"
                    : step.id === currentStep
                    ? "border-blue-500"
                    : "border-gray-300"
                }`}
              ></div>
            )}
          </div>
        ))}
      </div>
    </div>
  );
};

export default Stepper;