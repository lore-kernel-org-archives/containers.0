From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 0/3 net-2.6.25] call FIB rule->action in the correct namespace
Date: Thu, 17 Jan 2008 13:08:51 +0300
Message-ID: <478F2933.1000007@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
To: David Miller <davem@davemloft.net>
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>, netdev <netdev@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>, devel@openvz.org
List-Id: containers.vger.kernel.org

FIB rule->action should operate in the same namespace as fib_lookup.
This is definitely missed right now.

There are two ways to implement this: pass struct net into another rules
API call (2 levels) or place netns into rule struct directly. The second
approach seems better as the code will grow less.

Additionally, the patchset cleanups struct net from
fib_rules_register/unregister to have network namespace context at the
time of default rules creation.

Signed-off-by: Denis V. Lunev <den@openvz.org>
