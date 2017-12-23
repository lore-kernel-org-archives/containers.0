From: Dongsu Park <dongsu-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>
Subject: Re: [PATCH 04/11] fs: Don't remove suid for CAP_FSETID for userns root
Date: Sat, 23 Dec 2017 13:38:45 +0100
Message-ID: <CANxcAMtpE05xpOPt3Ua+4DkiTzkW5hOo4BBpiNZh_5+RTCfThA__46162.1431554251$1514032629$gmane$org@mail.gmail.com>
References: <cover.1512741134.git.dongsu@kinvolk.io>
	<ddf1fb9b5001e633e0022dee7fecb0ef431e851f.1512041070.git.dongsu@kinvolk.io>
	<20171223032606.GD6837@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20171223032606.GD6837-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,

On Sat, Dec 23, 2017 at 4:26 AM, Serge E. Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> wrote:
> On Fri, Dec 22, 2017 at 03:32:28PM +0100, Dongsu Park wrote:
>> From: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
>>
>> Expand the check in should_remove_suid() to keep privileges for
>
> I realize this description came from Seth, but reading it now,
> 'Expand' seems wrong.  Expanding a check brings to my mind making
> it stricter, not looser.  How about 'Relax the check' ?

Makes sense. Will do.

>> CAP_FSETID in s_user_ns rather than init_user_ns.
>>
>> Patch v4 is available: https://patchwork.kernel.org/patch/8944621/
>>
>> --EWB Changed from ns_capable(sb->s_user_ns, ) to capable_wrt_inode_uidgid
>
> Why exactly?
>
> This is wrong, because capable_wrt_inode_uidgid() does a check
> against current_user_ns, not the  inode->i_sb->s_user_ns

Ah. I see.
I suppose it was changed probably for the privileged_wrt_inode_uidgid()
called by capable_wrt_inode_uidgid(). But as you pointed out, that checks
against current_user_ns, which is wrong. I would just create another
wrapper like capable_userns_wrt_inode_uidgid(), which takes an
additional parameter of (struct user_namespace *), to be able to check for
both ns_capable() and privileged_wrt_inode_uidgid().

Thanks,
Dongsu

>> Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> Cc: Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
>> Cc: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
>> Signed-off-by: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
>> Signed-off-by: Dongsu Park <dongsu-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>
>> ---
>>  fs/inode.c | 6 ++++--
>>  1 file changed, 4 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/inode.c b/fs/inode.c
>> index fd401028..6459a437 100644
>> --- a/fs/inode.c
>> +++ b/fs/inode.c
>> @@ -1749,7 +1749,8 @@ EXPORT_SYMBOL(touch_atime);
>>   */
>>  int should_remove_suid(struct dentry *dentry)
>>  {
>> -     umode_t mode = d_inode(dentry)->i_mode;
>> +     struct inode *inode = d_inode(dentry);
>> +     umode_t mode = inode->i_mode;
>>       int kill = 0;
>>
>>       /* suid always must be killed */
>> @@ -1763,7 +1764,8 @@ int should_remove_suid(struct dentry *dentry)
>>       if (unlikely((mode & S_ISGID) && (mode & S_IXGRP)))
>>               kill |= ATTR_KILL_SGID;
>>
>> -     if (unlikely(kill && !capable(CAP_FSETID) && S_ISREG(mode)))
>> +     if (unlikely(kill && !capable_wrt_inode_uidgid(inode, CAP_FSETID) &&
>> +                  S_ISREG(mode)))
>>               return kill;
>>
>>       return 0;
>> --
>> 2.13.6
