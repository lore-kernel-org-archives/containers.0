From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [PATCH] [RFC] c/r: Add UTS support
Date: Fri, 13 Mar 2009 00:11:56 +0100
Message-ID: <49B996BC.1090908@free.fr>
References: <1236880612-15316-1-git-send-email-danms@us.ibm.com>	<20090312162954.4a4b8e00@thinkcentre.lan>	<87fxhipfrh.fsf@caffeine.danplanet.com>
	<49B99144.9000106@free.fr> <877i2upcvo.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <877i2upcvo.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Dan Smith wrote:
> DL> Assuming you have a process and this one unshared the network 100
> DL> times and each time opens a socket, how do you checkpoint these
> DL> namespaces ?
>
>   
>>> What's the argument for depending on userspace to set this up?
>>>
>>>       
> DL> Maybe, CR of the namespaces is more complicate topic than it looks
> DL> like and the CR itself is big enough to not complicate
> DL> things. IMHO, I would recommend as the first step to forbid the
> DL> unshare inside a container and let the container implementation to
> DL> save the configuration with the statefile in order to recreate it
> DL> at the restart
>
> I think what you're suggesting here is some sort of check to make sure
> we don't allow checkpointing a process with nested namespaces... is
> that correct?  If so, I agree.
>   
Correct.

I guess it will be esay to implement with a nsproxy level counter.
Each time you unshare, the new nsproxy count is incremented.
Assuming the init_nsproxy is level 0, when the nsproxy counter is > 1, 
the process is uncheckpointable.
