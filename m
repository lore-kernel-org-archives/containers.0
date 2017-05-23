From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC][PATCH 0/9] Make containers kernel objects
Date: Tue, 23 May 2017 10:17:26 -0500
Message-ID: <87bmqjmwl5.fsf@xmission.com>
References: <87zie3mxkc.fsf@xmission.com>
	<f167feeb-e653-12e3-eec8-24162f7f7c07@suse.de>
	<149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
	<1495472039.2757.19.camel@HansenPartnership.com>
	<2446.1495551216@warthog.procyon.org.uk>
	<2961.1495552481@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <2961.1495552481-S6HVgzuS8uM4Awkfq6JHfwNdhmdF6hFW@public.gmane.org> (David Howells's message
	of "Tue, 23 May 2017 16:14:41 +0100")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, trondmy-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org
List-Id: containers.vger.kernel.org

David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>
>> > As an example, I could set up a client machine with two ethernet ports,
>> > set up two DNS+NFS servers, each of which think they're called "foo.bar"
>> > and attach each server to a different port on the client machine.  Then I
>> > could create a pair of containers on the client machine and route the
>> > network in each container to a different port.  Now there's a problem
>> > because the names of the cached DNS records for each port overlap.
>> 
>> Please look at ip netns add.
>
> 	warthog>man ip | grep setns
> 	warthog1>

Not setns netns


>> It does solve this in userspace rather simply.
>
> Ummm...  How?  The kernel DNS resolver is not namespace aware.

But it works fine if called in the proper context and we have a defacto
standard for where to put all of the files (the tricky part) if you are
dealing with multiple network namespaces simultaneously.

Eric
