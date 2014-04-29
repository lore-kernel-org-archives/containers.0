From: Marian Marinov <mm-108MBtLGafw@public.gmane.org>
Subject: Re: ioctl CAP_LINUX_IMMUTABLE is checked in the wrong namespace
Date: Wed, 30 Apr 2014 01:24:51 +0300
Message-ID: <536026B3.1020905@1h.com>
References: <535FADDA.2070803@1h.com> <20140429183534.GB19325@thunk.org>
	<20140429185251.GA27969@ubuntumail> <53601E5B.5050004@1h.com>
	<20140429220234.GC28410@ubuntumail>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140429220234.GC28410@ubuntumail>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LXC development mailing-list <lxc-devel-cunTk1MwBs9qMoObBWhMNEqPaTDuhLve2LY78lusg7I@public.gmane.org>
List-Id: containers.vger.kernel.org

On 04/30/2014 01:02 AM, Serge Hallyn wrote:
> Quoting Marian Marinov (mm-108MBtLGafw@public.gmane.org):
>> On 04/29/2014 09:52 PM, Serge Hallyn wrote:
>>> Quoting Theodore Ts'o (tytso-3s7WtUTddSA@public.gmane.org):
>>>> On Tue, Apr 29, 2014 at 04:49:14PM +0300, Marian Marinov wrote:
>>>>>
>>>>> I'm proposing a fix to this, by replacing the capable(CAP_LINUX_IMMUTABLE)
>>>>> check with ns_capable(current_cred()->user_ns, CAP_LINUX_IMMUTABLE).
>>>>
>>>> Um, wouldn't it be better to simply fix the capable() function?
>>>>
>>>> /**
>>>>   * capable - Determine if the current task has a superior capability in effect
>>>>   * @cap: The capability to be tested for
>>>>   *
>>>>   * Return true if the current task has the given superior capability currently
>>>>   * available for use, false if not.
>>>>   *
>>>>   * This sets PF_SUPERPRIV on the task if the capability is available on the
>>>>   * assumption that it's about to be used.
>>>>   */
>>>> bool capable(int cap)
>>>> {
>>>> 	return ns_capable(&init_user_ns, cap);
>>>> }
>>>> EXPORT_SYMBOL(capable);
>>>>
>>>> The documentation states that it is for "the current task", and I
>>>> can't imagine any use case, where user namespaces are in effect, where
>>>> using init_user_ns would ever make sense.
>>>
>>> the init_user_ns represents the user_ns owning the object, not the
>>> subject.
>>>
>>> The patch by Marian is wrong.  Anyone can do 'clone(CLONE_NEWUSER)',
>>> setuid(0), execve, and end up satisfying 'ns_capable(current_cred()->userns,
>>> CAP_SYS_IMMUTABLE)' by definition.
>>>
>>> So NACK to that particular patch.  I'm not sure, but IIUC it should be
>>> safe to check against the userns owning the inode?
>>>
>>
>> So what you are proposing is to replace 'ns_capable(current_cred()->userns, CAP_SYS_IMMUTABLE)' with
>> 'inode_capable(inode, CAP_SYS_IMMUTABLE)' ?
>>
>> I agree that this is more sane.
>
> Right, and I think the two operations you're looking at seem sane
> to allow.

If you are ok with this patch, I will fix all file systems and send patches.

Signed-off-by: Marian Marinov <mm-NV7Lj0SOnH0@public.gmane.org>
---
  fs/ext4/ioctl.c | 2 +-
  1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/ext4/ioctl.c b/fs/ext4/ioctl.c
index d011b69..9418634 100644
--- a/fs/ext4/ioctl.c
+++ b/fs/ext4/ioctl.c
@@ -265,7 +265,7 @@ long ext4_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
                  * This test looks nicer. Thanks to Pauline Middelink
                  */
                 if ((flags ^ oldflags) & (EXT4_APPEND_FL | EXT4_IMMUTABLE_FL)) {
-                   if (!capable(CAP_LINUX_IMMUTABLE))
+                 if (!inode_capable(inode, CAP_LINUX_IMMUTABLE))
                                 goto flags_out;
                 }

---
1.8.4

Marian


>
> thanks,
> -serge
>


-- 
Marian Marinov
Founder & CEO of 1H Ltd.
Jabber/GTalk: hackman-/eSpBmjxGS4dnm+yROfE0A@public.gmane.org
ICQ: 7556201
Mobile: +359 886 660 270
