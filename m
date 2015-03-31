From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH] devpts: Add ptmx_uid and ptmx_gid options
Date: Tue, 31 Mar 2015 06:06:53 -0700
Message-ID: <CALCETrVpppJTz7v1dkajp87GNYvfBBVzuxopwXmBQDezSRsdmw@mail.gmail.com>
References: <b321c0c2729d1c2a72aea319b077dce7afd79698.1424480579.git.luto@amacapital.net>
	<CALCETrVtGE8LdBCFTe1_cqpLf=SxPNX5iCe5wa-hZ0pe8ps_jA@mail.gmail.com>
	<1427447013.2250.9.camel@HansenPartnership.com>
	<1427788642.4411.12.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1427788642.4411.12.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexander Larsson <alexl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: gnome-os-list-rDKQcyrBJuzYtjvyW6yDsg@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, mclasen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Mar 31, 2015 at 12:57 AM, Alexander Larsson <alexl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On fre, 2015-03-27 at 10:03 +0100, James Bottomley
>>
>> > On Fri, Feb 20, 2015 at 5:04 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
>> > > It's currently impossible to mount devpts in a user namespace that
>> > > has no root user, since ptmx can't be created.
>>
>> This is where I stopped reading because it's not true ... because it is
>> possible, you just do it from the host as real root.
>
> The point is being able to set up a container as a user, not requiring
> the setup to be run as root at all. In my case container is a desktop
> application which will be started by the user, and will run as the user.
> There is no root involved in the call chain at all.

Even more precisely, I think the status quo has less to do with the
privilege of the userns' creator and more to do with the configuration
of the userns.  Anyone (root or otherwise) can create a userns with or
without a "root" inside.  With the current code, if you create a
userns with no inner root, you can't mount devpts inside.

This gives no security benefit exactly because nonroot users *can*
create user namespaces that contain a root user.  In the use case for
this patch, the user doesn't want to do that and then gets stuck with
the current code.


--Andy


>
> --
> =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
>  Alexander Larsson                                            Red Hat, Inc
>        alexl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org            alexander.larsson-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
> He's a war-weary Catholic boxer for the 21st century. She's a beautiful
> renegade magician's assistant looking for love in all the wrong places.
> They fight crime!
>



-- 
Andy Lutomirski
AMA Capital Management, LLC
