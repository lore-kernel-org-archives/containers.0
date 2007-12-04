From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 0/4] netns: basic infrastructure for routing in the network
	namespace
Date: Tue, 4 Dec 2007 12:50:42 +0300
Message-ID: <20071204095042.GA5992@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
To: davem@davemloft.net
Cc: devel@openvz.org, containers@lists.osdl.org, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org

This set of patches provides a basic infrastructure for routing and further
IPv4 virtualization. Initialize flowi with a init namespace. Proper namespace
setup will follow step-by-step.

These patches has been originally sent to Herbert.
