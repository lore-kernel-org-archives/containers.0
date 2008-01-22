From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 0/12 net-2.6.25] [NETNS]: Routing namespacing on IP output
 path.
Date: Tue, 22 Jan 2008 18:58:54 +0300
Message-ID: <479612BE.8030409@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
To: David Miller <davem@davemloft.net>
Cc: netdev <netdev@vger.kernel.org>, devel@openvz.org, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

This set introduces namespacing in the IP output path. The namespace is
added to all routing API functions except ones with a valid socket. This
is very intrusive.

Routing cache is virtualized as a part of this efforts, though the hash
function is not tuned to use namespace id. This not required to work in
initial namespace.

ICMP replies now also use correct namespace.

Signed-off-by: Denis V. Lunev <den@openvz.org>


