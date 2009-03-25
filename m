From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] [RFC] c/r: Add UTS support
Date: Wed, 25 Mar 2009 05:01:16 -0700
Message-ID: <m1myb9x14j.fsf@fess.ebiederm.org>
References: <1236880612-15316-1-git-send-email-danms@us.ibm.com>
	<20090312162954.4a4b8e00@thinkcentre.lan>
	<87fxhipfrh.fsf@caffeine.danplanet.com> <49B99144.9000106@free.fr>
	<877i2upcvo.fsf@caffeine.danplanet.com> <49B996BC.1090908@free.fr>
	<873adipc5l.fsf@caffeine.danplanet.com> <49B999A6.2000005@free.fr>
	<20090313153004.GA8317@us.ibm.com> <49BA811C.4070302@free.fr>
	<20090313171556.GB10685@us.ibm.com> <49BA9D9C.2030208@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49BA9D9C.2030208-GANU6spQydw@public.gmane.org> (Daniel Lezcano's message of "Fri\,
	13 Mar 2009 18\:53\:32 +0100")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org> writes:

> Yes, this is an alternative. Maybe, I will say something stupid but IMO 
> the "maycheckpoint" will depends on what you assume you have for the CR:
>     1) the container is instantiated in one step, that is 
> clone(mycloneflags) and that's all, any other clone/unshare is 
> forbidden. In this case, you can concentrate the code in the nsproxy 
> structure.
>     2) the container can be instantiated in several steps, that is 
> several clone/unshare but with different namespaces. In this case, you 
> have to take care of all the namespaces and do a "maycheckpoint" for 
> each of them.

Please excuse me for jumping in late.

unshare/clone are irrelevant.  Think passing of file descriptors
in unix domain sockets.

Eric
