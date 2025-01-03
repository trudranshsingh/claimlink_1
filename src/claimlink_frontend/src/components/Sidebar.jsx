import React, { useState } from "react";
import { Link, useLocation } from "react-router-dom";
import { AiOutlineLink } from "react-icons/ai";
import { IoIosCloseCircle } from "react-icons/io";
import { RiNftFill, RiStackFill } from "react-icons/ri";
import { MdArrowOutward, MdDashboard, MdQrCode, MdMoney } from "react-icons/md";

const Sidebar = ({ setSidebarOpen }) => {
  const [isWhiteBackground, setWhiteBackground] = useState(true);
  const location = useLocation();
  const currentPath = location.pathname;

  const menuItems = [
    { path: "/dashboard", label: "Dashboard", icon: MdDashboard },
    { path: "/claim-link", label: "Claim links", icon: AiOutlineLink },
    { path: "/dispensers", label: "Dispensers", icon: RiStackFill },
    { path: "/qr-manager", label: "QR manager", icon: MdQrCode },
    { path: "/minter", label: "Minter", icon: MdMoney },
    { path: "/collected-nft", label: "Collected Nft", icon: RiNftFill },
  ];

  return (
    <>
      <div
        className={`sm:block sm:w-[250px] w-[100%] bg-white h-full overflow-y-auto scroll-hidden ${
          isWhiteBackground ? "bg-[#FBFAFC]" : "bg-gray-800"
        }  flex flex-col justify-between  px-2 transition-all duration-300 border-r border-gray-300`}
      >
        <div className="px-2">
          <p className="text-4xl w-full tracking-wide h-[88px] text-[#2E2C34]  items-center gap-2 justify-center flex">
            claimlink
            <MdArrowOutward className="bg-[#3B00B9] rounded text-white" />
            <IoIosCloseCircle
              className="text-[#3B00B9] rounded-full  bg-white  sm:hidden "
              onClick={setSidebarOpen}
            />
          </p>

          <div className="mb-4  space-y-2">
            {menuItems.map((item) => (
              <Link
                key={item.path}
                to={item.path}
                className={`flex items-center tracking-wide h-[48px] text-xs font-semibold gap-2 py-3 p-2 rounded transition duration-200 ${
                  currentPath === item.path || currentPath.startsWith(item.path)
                    ? "bg-[#dad6f797]  text-[#5542F6]"
                    : isWhiteBackground
                    ? "text-[#878097]"
                    : "text-white"
                } hover:bg-[#b8b2ea97]`}
              >
                <item.icon
                  className={`flex ${
                    currentPath === item.path ||
                    currentPath.startsWith(item.path)
                      ? "text-[#5542F6]"
                      : "text-gray-400"
                  } hover:text-[#5542F6]`}
                  size={20}
                />
                {item.label}
              </Link>
            ))}
          </div>
          <div className="mt-20">
            <div className="border-t border-gray-200 mb-2"></div>
            <Link
              to="/technical-help"
              className={`flex items-center py-3 px-2 tracking-wide mb-2 rounded  h-[32px] text-xs   font-semibold transition  duration-200 hover:bg-gray-300 ${
                isWhiteBackground ? " text-[#878097]" : "text-white"
              }`}
            >
              Technical Help
            </Link>
            <Link
              to="/contact-us"
              className={`py-3 px-2 rounded   h-[32px] tracking-wider text-xs   font-semibold flex items-center transition duration-200 hover:bg-gray-300 ${
                isWhiteBackground ? " text-[#878097]" : "text-white"
              }`}
            >
              Contact Us
            </Link>
          </div>
        </div>
      </div>
    </>
  );
};

export default Sidebar;
