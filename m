From: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 3/3] Enable security.selinux in user namespaces
Date: Fri, 23 Jun 2017 19:41:52 -0400
Message-ID: <f477e588-a557-65ae-13db-8e8a87955b7f@linux.vnet.ibm.com>
References: <1498157989-11814-1-git-send-email-stefanb@linux.vnet.ibm.com>
	<1498157989-11814-4-git-send-email-stefanb@linux.vnet.ibm.com>
	<1498249800.2063.9.camel@tycho.nsa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1498249800.2063.9.camel-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Stephen Smalley <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>, lkp-JC7UmRfGjtg@public.gmane.org, xiaolong.ye-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On 06/23/2017 04:30 PM, Stephen Smalley wrote:
> On Thu, 2017-06-22 at 14:59 -0400, Stefan Berger wrote:
>> Before the current modifications, SELinux extended attributes were
>> visible inside the user namespace but changes in patch 1 hid them.
>> This patch enables security.selinux in user namespaces and allows
>> them to be written to in the same way as security.capability.
>>
>> Signed-off-by: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
>> ---
>>   fs/xattr.c | 1 +
>>   1 file changed, 1 insertion(+)
>>
>> diff --git a/fs/xattr.c b/fs/xattr.c
>> index 045be85..37686ee 100644
>> --- a/fs/xattr.c
>> +++ b/fs/xattr.c
>> @@ -138,6 +138,7 @@ xattr_permission(struct inode *inode, const char
>> *name, int mask)
>>    */
>>   static const char *const userns_xattrs[] = {
>>   	XATTR_NAME_CAPS,
>> +	XATTR_NAME_SELINUX,
>>   	NULL
>>   };
>>   
> (cc SELinux maintainers, curiously omitted from these patches)
>
> I don't think this works for SELinux. You don't deal with actually
> supporting multiple security.selinux attributes within SELinux itself
> (and I'm not asking you to do so), and without such support, this can't
> operate as intended. With these patches applied, IIUC, a setxattr() of
> security.selinux within a userns will end up setting only security.seli
> nux@uid=1000 on disk, but will then tell SELinux to update its in-core
> security label to the new value (via security_inode_post_setxattr).
> Meanwhile, on a subsequent getxattr(), you'll call
> security_inode_getsecurity() with the security.selinux@uid=1000 name,
> which will always fail because SELinux doesn't know anything about your
> new scheme, and then you'll call the filesystem handler and returns its
> value, which is no longer connected in any way to the actual label
> being used by SELinux.  Also, SELinux itself makes calls to
> __vfs_getxattr() and __vfs_setxattr_noperm(), and I don't think your
> name remapping is correct in those cases.
>
> You also can't hide security.selinux within user namespaces.  Today
> userspace can get and set security.selinux attributes within user
> namespaces (if allowed by policy), and further can specify the label to
> use for new files via /proc/self/attr/fscreate, which unsurprisingly
> isn't addressed by your changes.  Changing that would be a userspace
> break.

I modified the 1st patch now in such a way that only security.capability 
is rewritten, security.selinux and all other ones remain untouched.

https://github.com/stefanberger/linux/commits/xattr_for_userns.v2

    Stefan
