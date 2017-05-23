From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: Re: [RFC][PATCH 0/9] Make containers kernel objects
Date: Tue, 23 May 2017 08:44:27 -0700
Message-ID: <1495554267.27369.9.camel__2616.83159410513$1495554275$gmane$org@HansenPartnership.com>
References: <87zie3mxkc.fsf@xmission.com>
	<f167feeb-e653-12e3-eec8-24162f7f7c07@suse.de>
	<149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
	<1495472039.2757.19.camel@HansenPartnership.com>
	<2446.1495551216@warthog.procyon.org.uk>
	<2961.1495552481@warthog.procyon.org.uk> <87bmqjmwl5.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87bmqjmwl5.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, trondmy-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 2017-05-23 at 10:17 -0500, Eric W. Biederman wrote:
> David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
> > Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> > > It does solve this in userspace rather simply.
> > 
> > Ummm...  How?  The kernel DNS resolver is not namespace aware.
> 
> But it works fine if called in the proper context and we have a 
> defacto standard for where to put all of the files (the tricky part) 
> if you are dealing with multiple network namespaces simultaneously.

I think you're missing each other's points slightly.

What David is pointing out is that the kernel has a DNS cache
(net/dns_resolver/) it can do name to IP translations, but isn't
namespaced.  Once it has one entry all containers would see it if they
cause a lookup to go through the kernel cache, so going through the
cache you can't have a name resolving to different IP addresses on a
per container basis.

I think Eric's point is that if you need the same DNS names resolving
to different IP addresses on a per container basis, you can do this in
userspace today but you have to disable the in-kernel DNS cache.

James
