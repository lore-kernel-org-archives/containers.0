From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [Part1 PATCH 00/22] Add namespace support for audit
Date: Wed, 19 Jun 2013 14:03:17 -0700
Message-ID: <87a9mlu82y.fsf@xmission.com>
References: <1371606834-5802-1-git-send-email-gaofeng@cn.fujitsu.com>
	<20130619204927.GJ3212@redhat.com>
	<1371675095.16587.5.camel@dhcp137-13.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1371675095.16587.5.camel-97fqgl+48DwtHMky1e46ABcY2uh10dtjAL8bYrjMMd8@public.gmane.org> (Eric
	Paris's message of "Wed, 19 Jun 2013 16:51:35 -0400")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, matthltc-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> On Wed, 2013-06-19 at 16:49 -0400, Aristeu Rozanski wrote:
>> On Wed, Jun 19, 2013 at 09:53:32AM +0800, Gao feng wrote:
>> > This patchset is first part of namespace support for audit.
>> > in this patchset, the mainly resources of audit system have
>> > been isolated. the audit filter, rules havn't been isolated
>> > now. It will be implemented in Part2. We finished the isolation
>> > of user audit message in this patchset.
>> > 
>> > I choose to assign audit to the user namespace.
>> > Right now,there are six kinds of namespaces, such as
>> > net, mount, ipc, pid, uts and user. the first five
>> > namespaces have special usage. the audit isn't suitable to
>> > belong to these five namespaces, And since the flag of system
>> > call clone is in short supply, we can't provide a new flag such
>> > as CLONE_NEWAUDIT to enable audit namespace separately. so the
>> > user namespace may be the best choice.
>> 
>> I thought it was said on the last submission that to tie userns and
>> audit namespace would be a bad idea?
>
> I consider it a non-starter.  unpriv users are allowed to launch their
> own user namespace.  The whole point of audit is to have only a priv
> user be allowed to make changes.  If you tied audit namespace to user
> namespace you grant an unpriv user the ability to modify audit.
>
> NAK.
>
> If there are not clone flags you will either need to only do this from
> unshare and not from clone, or get more flags to clone

I completely agree that only priveleged user should be able to make
changes.

On the flip side, I don't know if this is at all interesting unless we
have a solution that works for users in unprivileged user namespaces.
Something like having the possibility of two or more instances of audit
working on every action.  One for each layer of privilege.

Gao feng, how do you want to use the audit infrastructure?

Eric
