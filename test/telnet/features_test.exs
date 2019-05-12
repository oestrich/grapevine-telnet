defmodule GrapevineTelnet.FeaturesTest do
  use ExUnit.Case

  alias GrapevineTelnet.Features

  doctest Features

  describe "caching the packages that are enabled" do
    test "stores in the features map" do
      state = %{features: %Features{}}

      state = Features.packages(state, ["Character"])

      assert state.features.packages == ["Character"]
    end

    test "removes version number from the packages" do
      state = %{features: %Features{}}

      state = Features.packages(state, ["Character 1"])

      assert state.features.packages == ["Character"]
    end
  end

  describe "determining supported packaged based on state" do
    test "game is loaded" do
      game = %{gauges: [%{package: "Character 1"}, %{package: "Room 1"}]}

      packages = Features.supported_packages(%{game: game})

      assert packages == ["Character 1", "Room 1", "Client.Modals 1"]
    end

    test "loads from the client settings" do
      game = %{gauges: [], client_settings: %{character_package: "Character 1"}}

      packages = Features.supported_packages(%{game: game})

      assert packages == ["Character 1", "Client.Modals 1"]
    end

    test "client settings is not loaded properly" do
      game = %{gauges: [], client_settings: %{}}

      packages = Features.supported_packages(%{game: game})

      assert packages == ["Client.Modals 1"]
    end

    test "packages are uniqued" do
      game = %{
        gauges: [%{package: "Character 1"}, %{package: "Character 1"}],
        client_settings: %{character_package: "Character 1"}
      }

      packages = Features.supported_packages(%{game: game})

      assert packages == ["Character 1", "Client.Modals 1"]
    end

    test "no game is loaded" do
      assert Features.supported_packages(%{}) == []
      assert Features.supported_packages(%{game: nil}) == []
    end
  end

  describe "cache supported messages" do
    test "with a game" do
      game = %{gauges: [%{message: "Character.Vitals"}, %{message: "Room.Info"}]}

      state = Features.cache_supported_messages(%{game: game, features: %Features{}})

      assert state.features.messages == ["Character.Vitals", "Room.Info", "Client.Modals.Open"]
    end

    test "unique messages" do
      game = %{gauges: [%{message: "Character.Vitals"}, %{message: "Character.Vitals"}]}

      state = Features.cache_supported_messages(%{game: game, features: %Features{}})

      assert state.features.messages == ["Character.Vitals", "Client.Modals.Open"]
    end

    test "without a game" do
      state = Features.cache_supported_messages(%{game: nil, features: %Features{}})

      assert state.features.messages == []
    end
  end

  describe "checking if a message is enabled" do
    test "true if message is in the cache" do
      state = %{features: %{messages: ["Character.Vitals"]}}

      assert Features.message_enabled?(state, "Character.Vitals")
    end

    test "false otherwise" do
      state = %{features: %{messages: ["Character.Vitals"]}}

      refute Features.message_enabled?(state, "Core.Heartbeat")
    end
  end
end
