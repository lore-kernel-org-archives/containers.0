From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Mon, 8 Mar 2010 15:49:45 -0600
Message-ID: <20100308214945.GA26617__7332.46927052296$1268085214$gmane$org@us.ibm.com>
References: <4B92C886.9020507@free.fr> <m1fx4bxlfy.fsf@fess.ebiederm.org>
	<4B952BBE.6070507@free.fr> <m11vfuvi1t.fsf@fess.ebiederm.org>
	<4B9556A9.60206@free.fr> <m11vfusgsa.fsf@fess.ebiederm.org>
	<4B95611C.5060403@free.fr> <m1sk8ar15b.fsf@fess.ebiederm.org>
	<4B956852.7050804@free.fr> <m1lje2qzf4.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
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

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org> writes:
> I guess my meaning is I was expecting.
> child = fork();
> if (child == 0) {
> 	execve(...);
> }
> waitpid(child);
> 
> This puts /bin/sh in the container as well.
> 
> I'm not certain about the /proc/self thing I have never encountered that.
> But I guess if your pid is outside of the pid namespace of that instance
> of proc /proc/self will be a broken symlink.
> 
> Eric

Hmm, worse than a broken symlink, will it be a wrong symlink if just
the right pid is created in the container?

-serge
