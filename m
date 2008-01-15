From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/4] The control group itself
Date: Tue, 15 Jan 2008 11:49:41 -0600
Message-ID: <20080115174941.GA11638@sergelap.austin.ibm.com>
References: <47833C3A.8090106@openvz.org> <47833FF6.6060901@openvz.org>
	<20080114174056.GB15077@sergelap.austin.ibm.com>
	<478C6669.7070705@openvz.org>
	<20080115144440.GE4453@sergelap.austin.ibm.com>
	<6599ad830801150813s6a5a7374qd25b6d6206d5896a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <6599ad830801150813s6a5a7374qd25b6d6206d5896a-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Paul Menage (menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org):
> On Jan 15, 2008 6:44 AM, Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> >
> > I don't think so...  Wouldn't really make sense for the cgroup
> > infrastructure to presume to know what to enforce, and I don't see any
> > checks around the _write functions in cgroup.c, and no capable() calls
> > at all.
> 
> The cgroup filesystem can provide simple unix-level permissions on any
> given file. Am I right in thinking that having an entry in the mapper
> doesn't automatically give privileges for a device to the members of
> the cgroup, but they also have to have sufficient privilege in their
> own right? If so, that might be sufficient.

Oh, well actually I think what we'd want is to require both
CAP_NS_OVERRIDE and either CAP_MKNOD or CAP_SYS_ADMIN.  So it's probably
fine to leave this as is for now, and after I resend the patchset which
pushes CAP_NS_OVERRIDE (which is in a 4-patch userns patchset I've
been sitting on) the extra checks can be added.

> One other thought - should the parse/print routines themselves do a
> translation based on the device mappings for the writer/reader's
> cgroup? That way you could safely give a VE full permission to write
> to its children's device maps, but it would only be able to add/remap
> device targets that it could address itself.

Oh, well if we do this then we can just as well use the translation
functions to not allow a VE to add to its own set of devices, right?

Then maybe capable(CAP_NS_OVERRIDE|CAP_SYS_ADMIN) would only be required
to add devices.

Though there *is* some bit of danger to removing devices from a
privileged daemon, isn't there?  Though I can't think of examples
just now.  (Sorry, piercing headache, can't think quite right, will
think about this later)

-serge
