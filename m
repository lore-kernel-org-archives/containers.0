From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroup for disk quota
Date: Fri, 20 Feb 2009 17:44:07 +0100
Message-ID: <499EDDD7.2030908@fr.ibm.com>
References: <d95d44a20902200028h1e229cc0pa3cdd4f42814e78e@mail.gmail.com>
	<499EB403.9050403@fr.ibm.com>
	<d95d44a20902200830l1645e8b6j963f4ca62b5452f0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <d95d44a20902200830l1645e8b6j963f4ca62b5452f0-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: anqin <anqin.qin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

anqin wrote:
>>> BTW, I don't know how to submit a "useful" patch to kernel community. Or,
>>> maybe the patch is not useful at all and maybe has been developed by other
>>> developers. I very appreciate if both of experts could give me some
>>> commend.
>>> I will continue to develop cgroup-related codes to make contribution to
>>> kernel
>>> development.
>> I am not sure I understand what you mean by "useful", but it seems you did
>> an interesting feature. All the documentation related to submitting patches
>> is in Documentation/SubmittingPatches, I hope that helps.
>>
> 
> I learn from some kernel developers that they said only useful patches will be
> accepted by community and applied on next kernel mainstream version.
> So, I don't know whether or not my patch can be seen as "useful" by
> most of users while it is developed under my project requirements.
> 
> 
>> send your patches to lkml@ prefixed with [RFC] in the subject ('quilt' is
>> your friend). If the functionality already exists, someone will tell you.
>>
> 
> mmh...  SubmittingPatches said patches should be sent to
> linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org if there is not "MAINTAINERS file",
> after fixed into standard style.  what are different with that
> you have said? The " lkml@ prefixed " seems not be mentioned
> in SubmittingPatches, what should I do?

lkml@ = linux kernel mailing list aka linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

I think you will find the answers of all your questions here:
	http://kernelnewbies.org/UpstreamMerge

If you are looking for the recipients of your patches, IMO you should send:
	To: Paul Menage
	Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
	Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org

cf MAINTENERS file:

CONTROL GROUPS (CGROUPS)
P:      Paul Menage
M:      menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
L:      containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
S:      Maintained

Regards
   -- Daniel
