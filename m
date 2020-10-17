Return-Path: <SRS0=VhYk=DY=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A4BAC433E7
	for <containers@archiver.kernel.org>; Sat, 17 Oct 2020 15:04:50 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id C65C920708
	for <containers@archiver.kernel.org>; Sat, 17 Oct 2020 15:04:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C65C920708
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=xmission.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 28608203CC;
	Sat, 17 Oct 2020 15:04:49 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id pm7vnflvtsq5; Sat, 17 Oct 2020 15:04:43 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id B6667203D7;
	Sat, 17 Oct 2020 15:04:43 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 7B500C0052;
	Sat, 17 Oct 2020 15:04:43 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 7AF10C0051
 for <containers@lists.linux-foundation.org>;
 Sat, 17 Oct 2020 15:04:41 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 66520884E7
 for <containers@lists.linux-foundation.org>;
 Sat, 17 Oct 2020 15:04:41 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id dsu4cWvHEBaw
 for <containers@lists.linux-foundation.org>;
 Sat, 17 Oct 2020 15:04:40 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from out03.mta.xmission.com (out03.mta.xmission.com [166.70.13.233])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 24CF3884E2
 for <containers@lists.linux-foundation.org>;
 Sat, 17 Oct 2020 15:04:40 +0000 (UTC)
Received: from in02.mta.xmission.com ([166.70.13.52])
 by out03.mta.xmission.com with esmtps (TLS1.2) tls
 TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256 (Exim 4.93)
 (envelope-from <ebiederm@xmission.com>)
 id 1kTnkt-003kX6-Q2; Sat, 17 Oct 2020 09:04:23 -0600
Received: from ip68-227-160-95.om.om.cox.net ([68.227.160.95]
 helo=x220.xmission.com) by in02.mta.xmission.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_256_GCM_SHA384:256) (Exim 4.87)
 (envelope-from <ebiederm@xmission.com>)
 id 1kTnks-0008QQ-GQ; Sat, 17 Oct 2020 09:04:23 -0600
From: ebiederm@xmission.com (Eric W. Biederman)
To: "Serge E. Hallyn" <serge@hallyn.com>
References: <20200830143959.rhosiunyz5yqbr35@wittgenstein>
 <20201010042606.GA30062@mail.hallyn.com>
 <20201011205306.GC17441@localhost>
 <CALCETrUZcHNwspz315KFvSPxtK8MmLUPfiN=hCBgx+wqeJe4+g@mail.gmail.com>
 <87h7r0qbqi.fsf@x220.int.ebiederm.org>
 <20201012150006.GA3503@mail.hallyn.com>
 <87wnzsmvyx.fsf@x220.int.ebiederm.org>
 <20201015142709.GA25286@mail.hallyn.com>
Date: Sat, 17 Oct 2020 10:04:38 -0500
In-Reply-To: <20201015142709.GA25286@mail.hallyn.com> (Serge E. Hallyn's
 message of "Thu, 15 Oct 2020 09:27:09 -0500")
Message-ID: <87d01gj3ll.fsf@x220.int.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
X-XM-SPF: eid=1kTnks-0008QQ-GQ; ; ; mid=<87d01gj3ll.fsf@x220.int.ebiederm.org>;
 ; ; hst=in02.mta.xmission.com; ; ; ip=68.227.160.95; ; ;
 frm=ebiederm@xmission.com; ; ; spf=neutral
X-XM-AID: U2FsdGVkX192GxqEYID7yhHi/7T1nk6a+CvYfsRvuQ8=
X-SA-Exim-Connect-IP: 68.227.160.95
X-SA-Exim-Mail-From: ebiederm@xmission.com
Subject: Re: LPC 2020 Hackroom Session: summary and next steps for isolated
 user namespaces
X-SA-Exim-Version: 4.2.1 (built Thu, 05 May 2016 13:38:54 -0600)
X-SA-Exim-Scanned: Yes (on in02.mta.xmission.com)
Cc: Alexander Mihalicyn <alexander@mihalicyn.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Joseph Christopher Sible <jcsible@cert.org>, Kees Cook <keescook@chromium.org>,
 LKML <linux-kernel@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Josh Triplett <josh@joshtriplett.org>, Vivek Goyal <vgoyal@redhat.com>,
 Andy Lutomirski <luto@kernel.org>,
 =?utf-8?Q?Micka=C3=ABl_Sal?= =?utf-8?Q?a=C3=BCn?= <mic@digikod.net>,
 Wat Lim <watl@google.com>, Mrunal Patel <mpatel@redhat.com>,
 Pavel Tikhomirov <ptikhomirov@virtuozzo.com>,
 Geoffrey Thomas <geofft@ldpreload.com>
X-BeenThere: containers@lists.linux-foundation.org
X-Mailman-Version: 2.1.15
Precedence: list
List-Id: Linux Containers <containers.lists.linuxfoundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers@lists.linux-foundation.org>
List-Help: <mailto:containers-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

"Serge E. Hallyn" <serge@hallyn.com> writes:

> On Wed, Oct 14, 2020 at 02:46:46PM -0500, Eric W. Biederman wrote:
>> "Serge E. Hallyn" <serge@hallyn.com> writes:
>> 
>> > On Mon, Oct 12, 2020 at 12:01:09AM -0500, Eric W. Biederman wrote:
>> >> Andy Lutomirski <luto@kernel.org> writes:
>> >> 
>> >> > On Sun, Oct 11, 2020 at 1:53 PM Josh Triplett <josh@joshtriplett.org> wrote:
>> >> >>
>> >> >> On Fri, Oct 09, 2020 at 11:26:06PM -0500, Serge E. Hallyn wrote:
>> >> >> > > 3. Find a way to allow setgroups() in a user namespace while keeping
>> >> >> > >    in mind the case of groups used for negative access control.
>> >> >> > >    This was suggested by Josh Triplett and Geoffrey Thomas. Their idea was to
>> >> >> > >    investigate adding a prctl() to allow setgroups() to be called in a user
>> >> >> > >    namespace at the cost of restricting paths to the most restrictive
>> >> >> > >    permission. So if something is 0707 it needs to be treated as if it's 0000
>> >> >> > >    even though the caller is not in its owning group which is used for negative
>> >> >> > >    access control (how these new semantics will interact with ACLs will also
>> >> >> > >    need to be looked into).
>> >> >> >
>> >> >> > I should probably think this through more, but for this problem, would it
>> >> >> > not suffice to add a new prevgroups grouplist to the struct cred, maybe
>> >> >> > struct group_info *locked_groups, and every time an unprivileged task creates
>> >> >> > a new user namespace, add all its current groups to this list?
>> >> >>
>> >> >> So, effectively, you would be allowed to drop permissions, but
>> >> >> locked_groups would still be checked for restrictions?
>> >> >>
>> >> >> That seems like it'd introduce a new level of complexity (a new facet of
>> >> >> permission) to manage. Not opposed, but it does seem more complex than
>> >> >> just opting out of using groups for negative permissions.
>> >
>> > Yeah, it would, but I basically hoped that we could catch most of this at
>> > e.g. generic_permission(), and/or we could introduce a helper which
>> > automatically adds a check for permission denied from locked_groups, so
>> > it shouldn't be too wide-spread.  If it does end up showing up all over
>> > the place, then that's a good reason not to do this.
>> >
>> >> > Is there any context other than regular UNIX DAC in which groups can
>> >> > act as negative permissions or is this literally just an issue for
>> >> > files with a more restrictive group mode than other mode?
>> >> 
>> >> Just that.
>> >> 
>> >> The ideas kicked around in the conversation were some variant of having
>> >> a sysctl that says "This system never uses groups for negative
>> >> permissions".
>> >> 
>> >> It was also suggested that if the sysctl was set the the permission
>> >> checks would be altered such that even if someone tried to set a
>> >> negative permission, the more liberal permissions of other would be used
>> >> instead.
>> >
>> > So then this would touch all the same code points which the
>> > locked_groups approach would have to touch?
>> 
>> No locked_groups would touch in_group_p and set_groups.  Especially what
>> set_groups means in that context.  It would have to handle what happens
>> when you start accumulating locked groups (because of multiple
>> namespaces).  How you dedup locked groups etc.
>
> Well since group_info is sorted, you should be able to do a pretty
> simple and quick merge of current->locked_groups and
> current->group_info.  I suppose we'd have to consider a nasty user who
> is allocated 100k groups, sticks them all in groupinfo, then unshare
> twice, locking the kernel up for awhile, but that user can already hurt
> us.
>
>> I was not able to convince myself that not being able to clear out
>> groups that a user has when they create a user namespace won't cause
>> other problems.  Especially as user namespaces had been in use for a
>> while at that point.
>
> The locked_groups would *only* be considered for negative acls, right?

I had not seen that idea proposed.  I had assumed they would be
consulted in all cases for group membership in permission checks,
and that the only change would be to in_group_p and the code to
maintain the group lists.

> You would not *grant* any perms based on them.  It seems like exactly
> what you want.  If any user is denied perms on account of it, then that
> was the intent, and that's the whole reason we're having this problem.
> We are discussing whether it's ok to let a new user_ns be a way to
> bypass that restriction - not *looking* for a way to support bypassing
> it.
>
> I could state this as a more formal proof if you like.


If you modify the permission checks as you suggest it does seem easier
to reason about with respect to causing problems.  I would want to call
them denied_groups or something like that in the data structure for
clarity.

Howver there is a big question of how we deal with NFS.  NFS home
directories are currently a bit of a challenge for user namespaces
because the server performs the permission checks, and won't let
the userns root chown files from one user to another.

Negative groups would not be propogated to the NFS server (because they
are something new) and because they fail to propogate would fail to
preserve the property we are trying to preserve.

I think I need to reexamine the NFS issue.

Similarly user space processes outside the user namespace that check
if a process is a group for purposes of denying permissions might run
into the same issue if we had deny only groups.

>> Not supporting negative groups would touch acl_permission and modify it
>> like:
>> 
>>  static int acl_permission_check(struct inode *inode, int mask)
>>  {
>> [irrelveant code snipped]
>>  	/* Only RWX matters for group/other mode bits */
>>  	mask &= 7;
>>  
>>  	/*
>>  	 * Are the group permissions different from
>>  	 * the other permissions in the bits we care
>>  	 * about? Need to check group ownership if so.
>>  	 */
>>  	if (mask & (mode ^ (mode >> 3))) {
>> -		if (in_group_p(inode->i_gid))
>> +		if (in_group_p(inode->i_gid) &&
>> +		    (!sysctl_force_positive_groups ||
>> +		    (mask & ~(mode >> 3)))
>>  			mode >>= 3;
>>  	}
>>  
>>  	/* Bits in 'mode' clear that we require? */
>>  	return (mask & ~mode) ? -EACCES : 0;
>>  }
>> 
>> 
>> I don't know that we need to do that.  But it would might be a good way
>> of flushing out the issues.
>> 
>> 
>> >> Given that creating /etc/subgid is effectively opting out of negative
>> >> permissions already have a sysctl that says that upfront feels like a
>> >> very clean solution.
>> >> 
>> >> Eric
>> >
>> > That feels like a cop-out to me.  If some young admin at Roxxon Corp decides
>> > she needs to run a container, so installs subuid package and sets that sysctl,
>> > how does she know whether or not some previous admin, who has since retired and
>> > did not keep good docs, set things up so that a negative acl is keeping nginx
>> > from reading some supersecret doc?
>> >
>> > Now personally I'm not a great believer in the negative acls so I think the
>> > above is a very unlikely scenario, but if we're going to worry about it, then
>> > we should worry about it :)
>> 
>> There is a different between guaranting we don't break existing setups
>> when a new feature is enabled, and supporting old very rare setups when
>> a new feature is enabled.
>
> If the new feature is enabled by default, then no.  (I know the kernel
> kconfig =n, but these users likely are using a distribution, which
> probably enables it)
>
> And I also argue that if the new feature appears unrelated and is highly
> desirable, then again no.  Everyone these days wants to "enable
> container support" and it seems unrelated to using file permissions the
> way they appear meant to be used (I know I'm contradicting myself here
> :)  It's not like we are stopping support for an old architecture.  It's
> a behavior resulting from a combination of ordinary configuration pieces
> spread throught a system which is hard for a new admin to know is
> actually being used.  I guess let me put it this way:  I don't think
> that when a new admin is hired, she is told "Now remember, we use acls
> to deny file permissions to certain users based on their groupid, watch
> out for that."

I think it is a valid concern.

The question is do enough of those systems exist to matter.  Maybe.

I think our moral imperative is to honor the no regression rule.  You
are right that it is difficult to detect regressions in this area.

So far I have received exactly one report of a system using negative
groups.  That was Casey who was using this for some intel designed
distrubution that used smack.  I think the Nokia phones were playing
with it at the end before Nokia sold their phone division.

Casey still mentions on occasion that he is grumpy at the way setgroups
and user namespaces worked out.


>> > "Click this button if noone has ever used feature X on this server"
>> 
>> My current thinking is that if we already don't honor negative groups
>> when /etc/subgid exists it would not hurt to make that more explicit.
>
> Ok, if that's how everyone feels, then I'll step back.
>
> It was just an idea :)
>
> I prefer, in this case, a simple host-wide sysctl to allow setgroups.

Do you mean that you prefer the sysctl to just allow setgroups in a user
namespace not have the sysctl also disable negative groups?

>> >From what we could tell at the time people that know negative groups are
>> honored much less systems that actually use negative groups are
>> exceedingly rare.
>
> You're probably right, but again I think if you did a survey, many
> people who are using it probably answered no because they either
> forgot or don't think of it in those terms.

Quite possibly.

Still I haven't see any of the come forward and report problems.  Which
seems to indicate that the solution we came up with, with setgroups is
working and has not caused any regressions.

Eric

p.s.  One alternative that sticks slightly closer to what we have today
is to enable setgroups during the login process, like rlimits are set
today.  That has the same consequences for system security as
/etc/subuid and /etc/subgid and like a sysctl should just be a set and
forget option.




_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
