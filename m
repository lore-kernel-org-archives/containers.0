From: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/2] user_namespaces.7: Update the documention to reflect
	the fixes for negative groups
Date: Thu, 12 Feb 2015 11:11:09 +0100
Message-ID: <54DC7C3D.4040100__24875.2300198705$1423735893$gmane$org@gmail.com>
References: <52e0643bd47b1e5c65921d6e00aea1f724bb510a.1417281801.git.luto@amacapital.net>	<CALCETrU-o5mPr1jCaLXDuuF6J2N470zAtx=8Fa-SjF=ZpdE8mQ@mail.gmail.com>	<87ppbtn4mv.fsf@x220.int.ebiederm.org>	<CALCETrXSScp77BUJR5NSTh5-RnEZ9rqELSGJBeEzgdQ-OtohuQ@mail.gmail.com>	<87a92xn2io.fsf@x220.int.ebiederm.org>	<87r3w8liw4.fsf@x220.int.ebiederm.org>	<87iohklfvj.fsf_-_@x220.int.ebiederm.org>	<87fvcok11h.fsf_-_@x220.int.ebiederm.org>	<CALCETrVfKiXuY=KY_=nHpkTyLWgpy_3DK=4Mr2mhpyX9z1TzrA@mail.gmail.com>	<971ad3f6-90fd-4e3f-916c-8988af3c826d@email.android.com>	<CALCETrWpzvNm=fjOa3_+4QOqYP8qZUJvQAd6AsRZ71xyHZQRCg@mail.gmail.com>	<87wq5zf83t.fsf@x220.int.ebiederm.org>	<87iohh3c9c.fsf@x220.int.ebiederm.org>	<8761dh3b7k.fsf_-_@x220.int.ebiederm.org>	<878uicy1r9.fsf_-_@x220.int.ebiederm.org>	<87ppbo1ql4.fs
 f_-_@x220.int.ebiederm.org>
	<54CF99BF.8050401@gmail.com>	<CAKgNAkhmwK02DJQV84S+dEdrUDjzRuR32j+2gcKkgeDq8jTkuQ@mail.gmail.com>
	<87egpwk0n3.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87egpwk0n3.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: linux-man <linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Josh Triplett <josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org>, stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Kenton Varda <kenton-AuYgBwuPrUQTaNkGU808tA@public.gmane.org>, LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On 02/11/2015 03:01 PM, Eric W. Biederman wrote:
> "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
> 
>> Hi Eric,
>>
>> Ping!
>>
>> Cheers,
>>
>> Michael
>>
>>
>> On 2 February 2015 at 16:37, Michael Kerrisk (man-pages)
>> <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>> Hi Eric,
>>>
>>> Thanks for writing this up!
>>>
>>> On 12/12/2014 10:54 PM, Eric W. Biederman wrote:
>>>>
>>>> Files with access permissions such as ---rwx---rwx give fewer
>>>> permissions to their group then they do to everyone else.  Which means
>>>> dropping groups with setgroups(0, NULL) actually grants a process
>>>> privileges.
>>>>
>>>> The uprivileged setting of gid_map turned out not to be safe after
>         ^^^^^^^^^^^
> unprivileged  -- typo fix

Thanks for confirming.

>>>> this change.  Privilege setting of gid_map can be interpreted as
>>>> meaning yes it is ok to drop groups.
>>>
>>> I had trouble to parse that sentence (and I'd like to make sure that
>>> the right sentence ends up in the commit message). Did you mean:
>>>
>>>     "*Unprivileged* setting of gid_map can be interpreted as meaning
>>>      yes it is ok to drop groups"
>>> ?
>>>
>>> Or something else?
> 
> 
> I meant:  Setting of gid_map with privilege has been clarified to mean
> that dropping groups is ok.  This allows existing programs that set
> gid_map with privilege to work without changes.  That is newgidmap
> continues to work unchanged.

Thanks. I added that text to the changelog message.

Cheers,

Michael



-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
