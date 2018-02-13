From: Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 04/11] fs: Don't remove suid for CAP_FSETID for userns root
Date: Tue, 13 Feb 2018 14:37:12 +0100
Message-ID: <CAOssrKdse2_HKO0xweLD7uaBajZQArJ_URcLi9un6aLohqWxLg@mail.gmail.com>
References: <cover.1512741134.git.dongsu@kinvolk.io>
	<ddf1fb9b5001e633e0022dee7fecb0ef431e851f.1512041070.git.dongsu@kinvolk.io>
	<20171223032606.GD6837@mail.hallyn.com>
	<CANxcAMtpE05xpOPt3Ua+4DkiTzkW5hOo4BBpiNZh_5+RTCfThA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CANxcAMtpE05xpOPt3Ua+4DkiTzkW5hOo4BBpiNZh_5+RTCfThA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dongsu Park <dongsu-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sat, Dec 23, 2017 at 1:38 PM, Dongsu Park <dongsu-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org> wrote:
> Hi,
>
> On Sat, Dec 23, 2017 at 4:26 AM, Serge E. Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> wrote:
>> On Fri, Dec 22, 2017 at 03:32:28PM +0100, Dongsu Park wrote:
>>> From: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
>>>
>>> Expand the check in should_remove_suid() to keep privileges for
>>
>> I realize this description came from Seth, but reading it now,
>> 'Expand' seems wrong.  Expanding a check brings to my mind making
>> it stricter, not looser.  How about 'Relax the check' ?
>
> Makes sense. Will do.
>
>>> CAP_FSETID in s_user_ns rather than init_user_ns.
>>>
>>> Patch v4 is available: https://patchwork.kernel.org/patch/8944621/
>>>
>>> --EWB Changed from ns_capable(sb->s_user_ns, ) to capable_wrt_inode_uidgid
>>
>> Why exactly?
>>
>> This is wrong, because capable_wrt_inode_uidgid() does a check
>> against current_user_ns, not the  inode->i_sb->s_user_ns

I'm thoroughly confused.   s_user_ns is supposed to be about the
usernamespace the filesystem perceives to be in, right?  How does that
come into play when checking permissions to do something?

Thanks,
Miklos
