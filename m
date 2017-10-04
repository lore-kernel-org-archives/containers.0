From: Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>
Subject: Re: [PATCH] selinux: Perform both commoncap and selinux xattr checks
Date: Wed, 4 Oct 2017 10:53:54 -0400
Message-ID: <CAHC9VhQFGiE_VrN=oYODRP=rDSkM4Se5=XUcirUHxvMTC1Xf5w__27138.4137020961$1507128849$gmane$org@mail.gmail.com>
References: <87tvzmqwoi.fsf@xmission.com>
	<1506688601.5571.1.camel@tycho.nsa.gov>
	<873771ipib.fsf_-_@xmission.com>
	<CAHC9VhTzDKbP-h=GBaCTYOM9Sm=3C=nhNghmPoCRZitCpJj6YA@mail.gmail.com>
	<87a8179b3u.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87a8179b3u.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Chris Wright <chrisw-69jw2NvuJkxg9hUCZPvPmw@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>, Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>, Stephen Smalley <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Oct 3, 2017 at 5:26 PM, Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org> writes:
>
>> On Mon, Oct 2, 2017 at 10:38 AM, Eric W. Biederman
>> <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>>>
>>> When selinux is loaded the relax permission checks for writing
>>> security.capable are not honored.  Which keeps file capabilities
>>> from being used in user namespaces.
>>>
>>> Stephen Smalley <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org> writes:
>>>> Originally SELinux called the cap functions directly since there was no
>>>> stacking support in the infrastructure and one had to manually stack a
>>>> secondary module internally.  inode_setxattr and inode_removexattr
>>>> however were special cases because the cap functions would check
>>>> CAP_SYS_ADMIN for any non-capability attributes in the security.*
>>>> namespace, and we don't want to impose that requirement on setting
>>>> security.selinux.  Thus, we inlined the capabilities logic into the
>>>> selinux hook functions and adapted it appropriately.
>>>
>>> Now that the permission checks in commoncap have evolved this
>>> inlining of their contents has become a problem.  So restructure
>>> selinux_inode_removexattr, and selinux_inode_setxattr to call
>>> both the corresponding cap_inode_ function and dentry_has_perm
>>> when the attribute is not a selinux security xattr.   This ensures
>>> the policies of both commoncap and selinux are enforced.
>>>
>>> This results in smack and selinux having the same basic structure
>>> for setxattr and removexattr.  Performing their own special permission
>>> checks when it is their modules xattr being written to, and deferring
>>> to commoncap when that is not the case.  Then finally performing their
>>> generic module policy on all xattr writes.
>>>
>>> This structure is fine when you only consider stacking with the
>>> commoncap lsm, but it becomes a problem if two lsms that don't want
>>> the commoncap security checks on their own attributes need to be
>>> stack.  This means there will need to be updates in the future as lsm
>>> stacking is improved, but at least now the structure between smack and
>>> selinux is common making the code easier to refactor.
>>>
>>> This change also has the effect that selinux_linux_setotherxattr becomes
>>> unnecessary so it is removed.
>>>
>>> Fixes: 8db6c34f1dbc ("Introduce v3 namespaced file capabilities")
>>> Fixes: 7bbf0e052b76 ("[PATCH] selinux merge")
>>> Historical Tree: https://git.kernel.org/pub/scm/linux/kernel/git/tglx/history.git
>>> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>>> ---
>>>
>>> While this fixes some things this isn't a regression so it should be
>>> able to wait until the next merge window to be merged.   Would you like
>>> to take this through the selinux tree?  Or shall I take it through mine?
>>>
>>> security/selinux/hooks.c | 43 ++++++++++++++++++-------------------------
>>>  1 file changed, 18 insertions(+), 25 deletions(-)
>>
>> This patch looks sane to me and I believe it addresses Stephen's
>> concerns, but I'll wait on him to comment on-list.
>
> He has alredy acked this publicly.

So he did, for some reason I missed it in this thread, my apologies.

> I may have skipped Cc'ing the selinux list as the discussion was
> originally more general and the selinux list is reported to be
> subscribers (not me) only.

The list is quasi-open, non-members can post, they are just moderated.
That said I know the mailing list has been having some problems
lately.

>> As far as how this gets merged, I'd much prefer to take this via the
>> SELinux tree given that all of the changes are internal to SELinux.
>
> Sounds good.  I just care that it get's picked up.

Yep.  I just merged it into the SELinux next branch and I'll be
sending this up during the next merge window.

-- 
paul moore
www.paul-moore.com
