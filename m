From: "Mukesh G" <mukgbv-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Obtaining the latest kernel to test out the latest on the
	containers
Date: Tue, 1 Jul 2008 04:39:07 +0530
Message-ID: <c7704c490806301609n3437aa7dlbd191200ce4205ec@mail.gmail.com>
References: <c7704c490806241353s53493204g5db4ad45e77d238c@mail.gmail.com>
	<20080624222618.GA16783@us.ibm.com>
	<c7704c490806241652wb8862b2k9643fd902f4b9505@mail.gmail.com>
	<c7704c490806241654t56ccfe74k5711dfd81779ae1f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <c7704c490806241654t56ccfe74k5711dfd81779ae1f-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Disposition: inline
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Jun 25, 2008 at 5:24 AM, Mukesh G <mukgbv-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> Forget my question.... I found the answer...
>
> Thanks
>
>
>
>
> On Wed, Jun 25, 2008 at 5:22 AM, Mukesh G <mukgbv-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>
>> Another dumb question...
>>
>> Should I apply the patch against vanilla 2.6.26 kernel or apply it to the
>> mm branch?
>>
>> Thanks in advance
>>
>>
>>
>> On Wed, Jun 25, 2008 at 3:56 AM, Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>> wrote:
>>
>>> Quoting Mukesh G (mukgbv-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
>>> > Hi,
>>> >
>>> >     Where do I get the latest kernel sources to test out the latest on
>>> the
>>> > containers?
>>>
>>> Hi,
>>>
>>> generally go to lxc.sf.net and click on 'Patches'.  Currently the latest
>>> patchset is at:
>>>
>>>        http://lxc.sourceforge.net/patches/2.6.26/2.6.26-rc5-mm3-lxc1/
>>>
>>> Download the patch or the broken-out patchset, and apply on top of
>>> 2.6.26-rc5-mm3.  And please let us know how it goes!
>>>
>>> thanks,
>>> -serge
>>>
>>
>> Hi,
>

      I am having issues applying the patch set (2.6.26-rc5-mm3-lxc1) where
the patch fails for many files.

Here are the steps followed
1) Successfully installed 2.6.25-rc5 vanilla
2) Successfully applied patch 2.6.26-rc5-mm3 patch
3) Errors applying patch set 2.6.26-rc5-mm3-lxc1-broken-out

# patch -p1 </tmp/2.6.26-rc5-mm3-lxc1-broken-out.tar
patching file net/802/psnap.c
patching file net/ipv4/af_inet.c
patching file net/ipv6/af_inet6.c
patching file net/802/psnap.c
Reversed (or previously applied) patch detected!  Assume -R? [n] n
Apply anyway? [n] n
Skipping patch.
1 out of 1 hunk ignored -- saving rejects to file net/802/psnap.c.rej
patching file net/ipv4/af_inet.c
Reversed (or previously applied) patch detected!  Assume -R? [n] n
Apply anyway? [n] n
Skipping patch.
2 out of 2 hunks ignored -- saving rejects to file net/ipv4/af_inet.c.rej
patching file net/ipv6/af_inet6.c
Reversed (or previously applied) patch detected!  Assume -R? [n]
has anyone faced this problem before?

Thanks in advance

Mukesh
