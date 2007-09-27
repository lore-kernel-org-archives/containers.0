From: Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH] Devices visibility container
Date: Thu, 27 Sep 2007 08:46:45 -0700
Message-ID: <1190908005.20264.10.camel@localhost>
References: <46F77523.9020001@openvz.org>
	<m1r6kodn7t.fsf@ebiederm.dsl.xmission.com>
	<46F8BD33.5040108@openvz.org>
	<m13ax2eut7.fsf@ebiederm.dsl.xmission.com>
	<1190820972.26982.359.camel@localhost>
	<m1641xuttx.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1641xuttx.fsf-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 2007-09-26 at 13:09 -0600, Eric W. Biederman wrote:
> Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
> 
> > On Tue, 2007-09-25 at 07:30 -0600, Eric W. Biederman wrote:
> >> Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> writes:
> >> >
> >> > Oh! Can you provide us an example when after the migration some
> >> > device's major+minor pair change on the same device?
> >> 
> >> SCSI disks on a SAN.  Network accessible block devices.
> >> All kinds of logical/virtual devices like ttys, the loop device, and
> >> ramdisks.
> >> 
> >> It isn't especially frequent that something cares, but fundamentally
> >> the same issues apply.
> >
> > To be clear, this just covers cases where an application has
> > _internalized_ the device number, right?
> 
> Also cases where you want to call mknod in the container.

mknod of device files only, yeah.

> > Most applications should be pretty happy with the devices having
> > persistent device names across a restart, and we can do that with udev
> > and no kernel patching.
> 
> Yes.  But the applications that do internalize stat data from files
> aren't that uncommon.  git, and backup software etc.
>
> There is also a fair bit of work that is needed to get sysfs
> and the hotplug events isolated, when we start allowing mknod etc.
> 
> Basically if I figure if we are going to deal with this we need to handle
> the entire problem because these pieces are user visible.  I don't
> think it is a great priority.

Exactly.  We have to allow mknod before any of this gets interesting in
the least.  

-- Dave
