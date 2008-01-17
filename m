From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH 0/3 net-2.6.25] call FIB rule->action in the correct namespace
Date: Thu, 17 Jan 2008 11:41:36 +0100
Message-ID: <478F30E0.5090901@fr.ibm.com>
References: <478F2933.1000007@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <478F2933.1000007@openvz.org>
Sender: netdev-owner@vger.kernel.org
To: "Denis V. Lunev" <den@openvz.org>
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>, devel@openvz.org
List-Id: containers.vger.kernel.org

Denis V. Lunev wrote:
> FIB rule->action should operate in the same namespace as fib_lookup.
> This is definitely missed right now.
> 
> There are two ways to implement this: pass struct net into another rules
> API call (2 levels) or place netns into rule struct directly. The second
> approach seems better as the code will grow less.
> 
> Additionally, the patchset cleanups struct net from
> fib_rules_register/unregister to have network namespace context at the
> time of default rules creation.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Acked-by: Daniel Lezcano <dlezcano@fr.ibm.com>

-- 






















































Sauf indication contraire ci-dessus:
Compagnie IBM France
Sie`ge Social : Tour Descartes, 2, avenue Gambetta, La De'fense 5, 92400
Courbevoie
RCS Nanterre 552 118 465
Forme Sociale : S.A.S.
Capital Social : 542.737.118 ?
SIREN/SIRET : 552 118 465 02430
