From: Ralph-Gordon Paul <Ralph-Gordon.Paul-4bfl1RV3iZDOEhgYWvzSCYQuADTiUCJX@public.gmane.org>
Subject: Re: [PATCH 3/7] make CONFIG_CHECKPOINT depend
	onCONFIG_CHECKPOINT_SUPPORT
Date: Tue, 12 May 2009 14:42:21 +0200
Message-ID: <3A15FE99-C94B-467B-B475-44BBED892C25@uni-duesseldorf.de>
References: <1238022166-13422-1-git-send-email-ntl@pobox.com>
	<1238022166-13422-4-git-send-email-ntl@pobox.com>
	<FB599A4B-F618-4E6C-94D8-FC4EAE3D41D9@uni-duesseldorf.de>
	<20090512121001.GB28695@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-reply-to: <20090512121001.GB28695-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Ah okay sorry, i used this version: http://git.ncl.cs.columbia.edu/?p=linux-cr.git;a=shortlog;h=refs/heads/ckpt-v15

Is this the official place to download the up to date version ?

-Gordon

Am 12.05.2009 um 14:10 schrieb Serge E. Hallyn:

> Quoting Ralph-Gordon Paul (Ralph-Gordon.Paul-4bfl1RV3iZDOEhgYWvzSCYQuADTiUCJX@public.gmane.org):
>> Hi,
>>
>> in the kernel menuconfig, there should be a note, that
>> CHECKPOINT_SUPPORT depends on Compat VDSO (Processor type and  
>> features
>> --> Compad VDSO support).
>>
>> It took some time for me to find that out. :-)
>
> Wha?
>
> Oren, since you've taken Alexey's patch to update
> arch_setup_additional_pages() to take a start address, there should be
> no reason not to use that to remap the vdso, should there?
>
> We shouldn't depend on CONFIG_COMPAT_VDSO anymore.
>
> -serge
