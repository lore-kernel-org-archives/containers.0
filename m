From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Wed, 10 Mar 2010 22:16:05 +0100
Message-ID: <4B980C15.9000908__30460.7179867618$1268255823$gmane$org@free.fr>
References: <4B88E431.6040609@parallels.com>
	<4B8D28CF.8060304@parallels.com>	<20100302211942.GA17816@us.ibm.com>
	<m1y6iaqsmm.fsf@fess.ebiederm.org>	<20100303000743.GA13744@us.ibm.com>
	<m1ocj6qljj.fsf@fess.ebiederm.org>	<4B8E9370.3050300@parallels.com>
	<m17hptjh3m.fsf@fess.ebiederm.org>	<4B9158F5.5040205@parallels.com>
	<m1vdda1pmx.fsf@fess.ebiederm.org>	<4B926B1B.5070207@free.fr>
	<m1aaulyy5c.fsf@fess.ebiederm.org>	<4B92C886.9020507@free.fr>
	<m1fx4bxlfy.fsf@fess.ebiederm.org>	<4B952BBE.6070507@free.fr>
	<m11vfuvi1t.fsf@fess.ebiederm.org>	<4B9556A9.60206@free.fr>
	<m11vfusgsa.fsf@fess.ebiederm.org>	<4B95611C.5060403@free.fr>
	<m1sk8ar15b.fsf@fess.ebiederm.org>	<4B956852.7050804@free.fr>
	<m1lje2qzf4.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1lje2qzf4.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Netfilter Development Mailinglist <netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org> writes:
>   

[ ... ]

> I guess my meaning is I was expecting.
> child = fork();
> if (child == 0) {
> 	execve(...);
> }
> waitpid(child);
>
> This puts /bin/sh in the container as well.
>   

Eric,

at this point I did not fall in any obvious bug and I was able to enter 
/ execute commands directly inside the container.

Excellent !

Thanks
  -- Daniel
