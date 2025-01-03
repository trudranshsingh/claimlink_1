import { createBrowserRouter } from "react-router-dom";
import Dashboard from "../pages/Dashboard";
import Dashboardcontainer from "../pages/Dashboardcontainer";
import Dispensers from "../pages/Dispensers";
import CreateDispensers from "../components/dispensers/CreateDispenser";
import DispenserSetup from "../components/dispensers/DispenserSetup";
import CreateDispenser from "../components/dispensers/CreateDispenser";
import CampaignSetup from "../components/claimlink/CampaignSetup";
import ClaimPattern from "../components/claimlink/ClaimPattern";
import DistributionPage from "../components/claimlink/DistributionPage";
import Minter from "../pages/Minter";
import SelectContractType from "../components/minter/SelectContractType";
import CollectionSetup from "../components/minter/CollectionSetup";
import AddToken from "../components/minter/AddToken";
import AddTokenHome from "../components/minter/AddTokenHome";
import Launch from "../components/claimlink/Launch";
import TestCampaign from "../components/claimlink/TestCampaign";
import TestCampaign2 from "../components/qrManager/TestCampaign2";
import QrManager from "../pages/QrManager";
import QrSetup from "../components/qrManager/QrSetup";
import QRSetForm from "../components/qrManager/NewQrSet";
import DistributionPages from "../components/minter/DistributionPages";
import LoginPage from "../components/LoginPage";
import Contract from "../components/minter/Contract";
import MainHome from "../pages/MainHome";
import ClaimForm from "../components/claimlink/ClaimForm";
import QrForm from "../components/qrManager/QrForm";
import LinkClaiming from "../LinkClaiming";
import TestCollection from "../components/claimlink/TestCampaign";
import { DisclosurePanel } from "@headlessui/react";
import DispenserForm from "../components/dispensers/DispenserForm";
import UsersNft from "../pages/UsersNft";
import DispenserClaimNFT from "../DispenserClaimNFT";
import ContactUs from "../pages/ContactUs";
import UserNft2 from "../pages/UserNft2";
import NotFound from "../pages/NotFound";
import TechnicalHelp from "../common/TechnicalHelp";
import Nfidlogin from "../common/NfidWallet";
import NfidPAyment from "../common/NfidPAyment";
import TermCondition from "../common/TermCondition";
import Privacy from "../common/Privacy";

const approutes = createBrowserRouter([
  {
    path: "/",
    element: <MainHome />,
  },

  {
    path: "*",
    element: <NotFound />,
  },

  {
    path: "/dashboard",
    element: <Dashboard />,
  },
  {
    path: "/login",
    element: <LoginPage />,
  },
  // {
  //   path: "/nfid",
  //   element: <NfidPAyment />,
  // },
  {
    path: "/claim-link",
    element: (
      <Dashboard stepper={false} headerText={" Campaign"} menubar={true}>
        <Dashboardcontainer />
      </Dashboard>
    ),
  },
  {
    path: `/claim-link/:campaignId`,
    element: (
      <Dashboard stepper={false} headerText={"Campaign"} menubar={false}>
        <TestCollection />
      </Dashboard>
    ),
  },
  {
    path: "/dispensers",
    element: (
      <Dashboard headerText={"Dispensers"} menubar={true}>
        <Dispensers />
      </Dashboard>
    ),
  },
  {
    path: "/collected-nft",
    element: (
      <Dashboard headerText={"Collected Nft"} menubar={true}>
        <UsersNft />
      </Dashboard>
    ),
  },
  {
    path: "/collected-nft/:id",
    element: (
      <Dashboard headerText={"Users Nft"} menubar={false}>
        <UserNft2 />
      </Dashboard>
    ),
  },
  {
    path: "/contact-us",
    element: (
      <Dashboard headerText={"Contact"} menubar={true}>
        <ContactUs />
      </Dashboard>
    ),
  },

  // {
  //   path: "/dispensers/create-dispenser",
  //   element: (
  //     <Dashboard>
  //       <CreateDispenser />
  //     </Dashboard>
  //   ),
  // },
  {
    path: "/dispensers/dispenser-setup",
    element: (
      <Dashboard stepper={true} headerText={"New dispenser"} menubar={false}>
        <DispenserForm />
      </Dashboard>
    ),
  },
  {
    path: "/claim-link/launch",
    element: (
      <Dashboard stepper={true}>
        <Launch />
      </Dashboard>
    ),
  },
  {
    path: "/claim-link/test-campaign",
    element: (
      <Dashboard>
        <TestCampaign />
      </Dashboard>
    ),
  },
  {
    path: "/campaign-setup",
    element: (
      <Dashboard stepper={true}>
        <ClaimForm />
      </Dashboard>
    ),
  },
  {
    path: "/minter",
    element: (
      <Dashboard>
        <Minter />
      </Dashboard>
    ),
  },

  {
    path: "/minter/new-contract",
    element: (
      <Dashboard stepper={true}>
        <Contract />
      </Dashboard>
    ),
  },
  {
    path: "/distribution",
    element: (
      <Dashboard stepper={true}>
        <DistributionPage />
      </Dashboard>
    ),
  },
  {
    path: "/qr-manager",
    element: (
      <Dashboard>
        <QrManager />
      </Dashboard>
    ),
  },
  {
    path: "/qr-manager/:id",
    element: (
      <Dashboard>
        <TestCampaign2 />
      </Dashboard>
    ),
  },
  {
    path: "/qr-setup",
    element: (
      <Dashboard stepper={true}>
        <QrForm />
      </Dashboard>
    ),
  },
  {
    path: "/new-qr-setup",
    element: (
      <Dashboard>
        <QRSetForm />
      </Dashboard>
    ),
  },
  // {
  //   path: "/minter/new-contract/collection-setup",
  //   element: (
  //     <Dashboard stepper={true}>
  //       <CollectionSetup />
  //     </Dashboard>
  //   ),
  // },
  {
    path: "/minter/:id/token-home",
    element: (
      <Dashboard>
        <AddTokenHome />
      </Dashboard>
    ),
  },
  {
    path: "/minter/:id",
    element: (
      <Dashboard>
        <AddTokenHome />
      </Dashboard>
    ),
  },
  {
    path: "/minter/:id/token-home/add-token",
    element: (
      <Dashboard>
        <AddToken />
      </Dashboard>
    ),
  },
  {
    path: "/minter/new-contract/distribution-setup",
    element: (
      <Dashboard stepper={true} headerText={"Test campaign"} menubar={false}>
        <DistributionPages />
      </Dashboard>
    ),
  },
  {
    path: "technical-help",
    element: (
      <Dashboard>
        <TechnicalHelp />
      </Dashboard>
    ),
  },
  {
    path: "/linkclaiming/:id/:id",
    element: <LinkClaiming />,
  },
  {
    path: "dispensers/:id",
    element: <DispenserClaimNFT />,
  },
  {
    path: "/term-of-service",
    element: <TermCondition />,
  },
  {
    path: "/privacy-policy",
    element: <Privacy />,
  },
]);

export default approutes;
