From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 3/7] make
	CONFIG_CHECKPOINT	dependonCONFIG_CHECKPOINT_SUPPORT
Date: Tue, 12 May 2009 12:16:20 -0400
Message-ID: <4A09A0D4.40208@cs.columbia.edu>
References: <1238022166-13422-1-git-send-email-ntl@pobox.com>
	<1238022166-13422-4-git-send-email-ntl@pobox.com>
	<FB599A4B-F618-4E6C-94D8-FC4EAE3D41D9@uni-duesseldorf.de>
	<20090512121001.GB28695@us.ibm.com>
	<3A15FE99-C94B-467B-B475-44BBED892C25@uni-duesseldorf.de>
	<20090512142912.GA31449@us.ibm.com>
	<4A0992CB.9050404@cs.columbia.edu>
	<20090512154455.GA32658@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090512154455.GA32658-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Ralph-Gordon Paul <Ralph-Gordon.Paul-4bfl1RV3iZDOEhgYWvzSCYQuADTiUCJX@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
>> Hi Gordon,
>>
>> Serge E. Hallyn wrote:
>>> Quoting Ralph-Gordon Paul (Ralph-Gordon.Paul-4bfl1RV3iZDOEhgYWvzSCYQuADTiUCJX@public.gmane.org):
>>>> Ah okay sorry, i used this version: http://git.ncl.cs.columbia.edu/?p=linux-cr.git;a=shortlog;h=refs/heads/ckpt-v15
>>>>
>>>> Is this the official place to download the up to date version ?
>> ckpt-v15 branch per-se is a snapshot of the patchset as it was released.
>>
>> ckpt-v15-dev is the development branch that is based on ckpt-v15, and is
>> probably what you want to use.
>>
>> the userspace utilities are in the matching v15-dev in 'user-cr.git'.
>>
>>>> -Gordon
>>> Hi Gordon,
>>>
>>> yes, and you were right about needing compat vdso.  Sorry about the
>>> inconvenience (since it was my patch).  I was just saying that since
>>> Oren has added the underlying code for moving vdso around, there is no
>>> reason why we shouldn't complete that support (with 1 line of code)
>>> allowing us to remove the dependency on CONFIG_COMPAT_VDSO.
>> True, no need to keep that dependency. Will remove.
>>
>> Note, however, that we still don't handle the case where the contents of
>> the VDSO page(s) differ between checkpoint and restart time...  So it's
>> on the todo list to at least detect that the format changed.
> 
> sigh - yeah, and we still haven't decided how to cleanly solve that,
> have we...  (apart from some arch-specific memcmp template/map that
> compares the code and not data...)

Heh .. I thought we outlined a suitable solution:

* On checkpoint, save the contents of the VDSO page(s), or their hash,
  but not including any dynamic data exported by the kernel. The VDSO
  contents themselves should be a shared object.

* On restart, compare the contents, or their hash, with the local
  kenrel; If there is a match -- all well. If not - need to provide
  some compatibility code in place of the original VDSO.

The gory details .. oh well ...

Oren.
