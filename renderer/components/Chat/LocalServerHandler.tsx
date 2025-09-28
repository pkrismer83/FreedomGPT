import { useModel } from "@/context/ModelSelection";
import socket from "@/socket/socket";
import { currentModelPath } from "@/utils/app/localModels";
import React from "react";
import toast from "react-hot-toast";

const LocalServerHandler: React.FC = () => {
  const { localServer, setLocalServer, selectedModel, vsRedistStatus } = useModel();

  const getVSRedistStatusInfo = () => {
    switch (vsRedistStatus) {
      case 'installing':
        return {
          status: 'Installing Visual C++ Redistributable...',
          color: 'bg-yellow-500 text-black dark:text-white',
          show: true
        };
      case 'installed':
        return {
          status: 'Visual C++ Redistributable installed',
          color: 'bg-green-500 text-black dark:text-white',
          show: true
        };
      case 'error':
        return {
          status: 'Visual C++ Redistributable installation failed',
          color: 'bg-red-500 text-black dark:text-white',
          show: true
        };
      case 'checking':
        return {
          status: 'Checking Visual C++ Redistributable...',
          color: 'bg-blue-500 text-black dark:text-white',
          show: true
        };
      case 'not_required':
      default:
        return {
          status: '',
          color: '',
          show: false
        };
    }
  };

  const startServer = () => {
    if (!selectedModel.model) {
      toast.error("No model selected, Download a model first");
      window.location.href = "/ai-cortex";
      return;
    }

    setLocalServer({
      serverStatus: "loading",
      serverMessage: "Local server is loading",
      model: selectedModel,
    });

    const inferenceProcessConfig = [
      "-m",
      currentModelPath(selectedModel.id),
      "-c",
      "2048",
      "--port",
      "8887",
    ];

    socket && socket.emit("select_model", inferenceProcessConfig);
  };

  const stopServer = () => {
    socket && socket.emit("kill_process");

    setLocalServer({
      serverStatus: "stopped",
      serverMessage: "Local server is stopped",
      model: selectedModel,
    });
  };

  return (
    <>
      <div
        className="pl-[40px] pr-[40px]"
        style={{
          display: "flex",
          flexDirection: "column",
          justifyContent: "center",
          alignItems: "center",
          padding: "20px",
        }}
      >
        <div>
          <p className="font-bold text-lg mb-2 text-cyan-600">
            Server Information
          </p>
          <div className="flex flex-col">
            <div className="mb-2">
              <span className="font-semibold text-black dark:text-white">
                Server Status:{" "}
              </span>
              <span
                className={`inline-block px-2 py-1 rounded ${
                  localServer.serverStatus === "running"
                    ? "bg-green-500 text-black dark:text-white"
                    : localServer.serverStatus === "loading"
                    ? "bg-yellow-500 text-black dark:text-white"
                    : "bg-red-500 text-black dark:text-white"
                }`}
              >
                {localServer.serverStatus}
              </span>
            </div>
            {getVSRedistStatusInfo().show && (
              <div className="mb-2">
                <span className="font-semibold text-black dark:text-white">
                  System Status:{" "}
                </span>
                <span
                  className={`inline-block px-2 py-1 rounded ${getVSRedistStatusInfo().color}`}
                >
                  {getVSRedistStatusInfo().status}
                </span>
              </div>
            )}
            <div className="mb-2">
              <span className="font-semibold text-black dark:text-white">
                Model:
              </span>{" "}
              <span className="text-black dark:text-white">
                {selectedModel.id}
              </span>
            </div>
            <div className="mb-2">
              <span className="font-semibold text-black dark:text-white">
                Location:
              </span>{" "}
              <span className="text-black dark:text-white">
                {currentModelPath(selectedModel.id)}
              </span>
            </div>
          </div>
        </div>

        {localServer.serverStatus === "running" ? (
          <button
            className="bg-red-500 hover:bg-red-700 text-white font-bold py-2 px-4 rounded"
            onClick={() => {
              stopServer();
            }}
          >
            Stop Local Server
          </button>
        ) : (
          <button
            className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded mt-4"
            onClick={() => {
              startServer();
            }}
          >
            Start Local Server
          </button>
        )}
      </div>
    </>
  );
};

export default LocalServerHandler;
