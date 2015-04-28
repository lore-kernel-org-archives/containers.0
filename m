From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH V6 00/10] namespaces: log namespaces per task
Date: Mon, 27 Apr 2015 21:16:32 -0500
Message-ID: <87zj5tgfpb.fsf@x220.int.ebiederm.org>
References: <cover.1429252659.git.rgb@redhat.com>
	<87vbgqw163.fsf@x220.int.ebiederm.org>
	<20150423030751.GA6712@madcap2.tricolour.ca>
	<20150423204429.GA25794@madcap2.tricolour.ca>
	<87bnid9v4f.fsf@x220.int.ebiederm.org>
	<20150428020555.GB20713@madcap2.tricolour.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20150428020555.GB20713-bcJWsdo4jJjeVoXN4CMphl7TgLCtbB0G@public.gmane.org> (Richard Guy
	Briggs's message of "Mon, 27 Apr 2015 22:05:55 -0400")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> On 15/04/24, Eric W. Biederman wrote:
>> Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
>> > On 15/04/22, Richard Guy Briggs wrote:
>> >> On 15/04/20, Eric W. Biederman wrote:
>> >> > Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
>> >> > 
>> >
>> > Do I even need to report the device number anymore since I am concluding
>> > s_dev is never set (or always zero) in the nsfs filesystem by
>> > mount_pseudo() and isn't even mountable? 
>> 
>> We still need the dev. We do have a device number get_anon_bdev fills it in.
>
> Fine, it has a device number.  There appears to be only one of these
> allocated per kernel.  I can get it from &nsfs->fs_supers (and take the
> first instance given by hlist_for_each_entry and verify there are no
> others).  Why do I need it, again?

Because if we have to preserve the inode number over a migration event I
want to preserve the fact that we are talking about inode numbers from a
superblock with a device number.

Otherwise known as I am allergic to kernel global identifiers, because
they can be major pains.  I don't want to have to go back and implement
a namespace for namespaces.

>> >> They are all covered:
>> >> sys_unshare > unshare_userns > create_user_ns
>> >> sys_unshare > unshare_nsproxy_namespaces > create_new_namespaces > copy_mnt_ns
>> >> sys_unshare > unshare_nsproxy_namespaces > create_new_namespaces > copy_utsname > clone_uts_ns
>> >> sys_unshare > unshare_nsproxy_namespaces > create_new_namespaces > copy_ipcs > get_ipc_ns
>> >> sys_unshare > unshare_nsproxy_namespaces > create_new_namespaces > copy_pid_ns > create_pid_namespace
>> >> sys_unshare > unshare_nsproxy_namespaces > create_new_namespaces > copy_net_ns
>> 
>> Then why the special change to fork?  That was not reflected on
>> the unshare path as far as I could see.
>
> Fork can specify more than one CLONE flag at once, so collecting them
> all in one statementn seemed helpful.  setns can only set one at a time.

unshare can also specify more than one CLONE flag at once.

I just pointed that out becase that seemed really unsymmetrical.

> Ok, understood, we can't just punt this one to a higher layer...
>
> So this comes back to a question above, which is how do we determine
> which device it is from?  Sounds like we need something added to
> ns_common or one of the 6 namespace types structs.

Or we can just hard code reading it off of the appropriate magic
filesystem.  Probably what we want is a well named helper function that
does the job.

I just care that when we talk about these things we are talking about
inode numbers from a superblock that is associated with a given device
number.  That way I don't have nightmares about dealing with a namespace
for namespaces.

Eric
