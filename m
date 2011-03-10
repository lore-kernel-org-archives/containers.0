From: =?ISO-8859-1?Q?Carlos_N=2E_A=2E_Corr=EAa?= <carlos.nilton-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Hot-add network devices in liblxc
Date: Thu, 10 Mar 2011 17:26:34 -0300
Message-ID: <AANLkTi=1PjTyDZmregswa9h9DiMa8qF7ZQLypTf99GD9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi, people.

I'm trying to implement a mechanism to permit the addition of a new network
device to a container "on-the-fly".

That would be useful to me in some complex virtual networking scenarios,
where a container need to connect to a newborn bridge and I can't stand to
lxc-stop/modify config manually/lxc-start.

I'm thinking about:

1. Hacking commands.(h|c) to create a new callback for hot netdev addition
2. Implement the callback through a call to instanciate_(veth|macvlan|etc)
3. Updating lxc_handler->conf->network by adding a new netdev to the list

Could this be accomplished some other way? Do you think that it could be
useful to others?

Best regards,
Carlos "Bill" Nilton
CISSP, RHCE, ITIL Foundations
http://carlosnilton.com.br/
