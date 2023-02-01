import { useWallet } from "@aptos-labs/wallet-adapter-react";
import Button from "components/Button.js";
import Modal from "components/Modal.js";
import React, { useEffect, useState } from "react";
import { abbreviateAddress } from "utils/address.js";

export default function ConnectWalletButton() {
  const [modalVisible, setModalVisible] = useState(false);
  const { connect, account, connected, disconnect, wallets } = useWallet();

  useEffect(() => {
    if (connected) setModalVisible(false);
  }, [connected]);

  return (
    <>
      <Button
        className="pointer-events-auto"
        onClick={() => setModalVisible(true)}
      >
        {connected && account
          ? abbreviateAddress(account.address)
          : "Connect Wallet"}
      </Button>
      <Modal visible={modalVisible} close={() => setModalVisible(false)}>
        <div className="flex flex-col pt-[60px]">
          <img
            className="h-[80px] w-[80px] self-center"
            src="/assets/logo-single@2x.png"
            alt=""
          />
          <div className="mt-[10px] text-center text-[22px] font-bold text-primary">
            Connect Wallet
          </div>

          <div className="relative mt-[60px] flex flex-wrap justify-between">
            {wallets.map(({ name, icon, url, readyState }) => {
              const installed = readyState === "Installed";
              const borderColor = installed
                ? "border-[#dfcefd]"
                : "border-[#2a1636]";

              const textColor = installed ? "text-primary" : "text-[#8a6eaa]";

              return (
                <div
                  key={name}
                  className={`mb-[10px] flex h-[93px] w-full cursor-pointer flex-col border p-[15px] mobile:w-[calc(50%-5px)] ${borderColor} ${textColor}`}
                  onClick={() => {
                    if (!installed) {
                      window.open(url, "_blank");
                      return;
                    }
                    connect(name);
                  }}
                >
                  <div className="flex flex-grow items-start">
                    <div className="flex items-center">
                      <img className="h-[24px] w-[24px]" src={icon} alt="" />
                      <div className="ml-[10px] text-sm">{name}</div>
                    </div>
                  </div>

                  <div
                    className={`flex h-[18px] w-[55px] items-center justify-center self-end border text-[11px] font-bold ${borderColor}`}
                  >
                    {installed ? "Connect" : "Install"}
                  </div>
                </div>
              );
            })}
          </div>
          {connected && account && (
            <Button
              className="mt-[20px] w-full bg-transparent"
              onClick={() => disconnect?.()}
            >
              Disconnect from {abbreviateAddress(account.address)}
            </Button>
          )}
        </div>
      </Modal>
    </>
  );
}
