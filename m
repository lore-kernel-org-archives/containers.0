From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/4] The control group itself
Date: Tue, 15 Jan 2008 12:17:17 -0600
Message-ID: <20080115181717.GA12249@sergelap.austin.ibm.com>
References: <47833C3A.8090106@openvz.org> <47833FF6.6060901@openvz.org>
	<20080114174056.GB15077@sergelap.austin.ibm.com>
	<478C6669.7070705@openvz.org>
	<20080115144440.GE4453@sergelap.austin.ibm.com>
	<6599ad830801150813s6a5a7374qd25b6d6206d5896a@mail.gmail.com>
	<20080115174941.GA11638@sergelap.austin.ibm.com>
	<6599ad830801150954w7e1b6db0p4dd737730f407348@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <6599ad830801150954w7e1b6db0p4dd737730f407348-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
> On Jan 15, 2008 9:49 AM, Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> > > One other thought - should the parse/print routines themselves do a
> > > translation based on the device mappings for the writer/reader's
> > > cgroup? That way you could safely give a VE full permission to write
> > > to its children's device maps, but it would only be able to add/remap
> > > device targets that it could address itself.
> >
> > Oh, well if we do this then we can just as well use the translation
> > functions to not allow a VE to add to its own set of devices, right?
> 
> Right.
> 
> >
> > Then maybe capable(CAP_NS_OVERRIDE|CAP_SYS_ADMIN) would only be required
> > to add devices.
> 
> Or simply require that they be added by someone who already has access
> to that device via their own control group? The root cgroup would have
> access to all devices.

Where by 'have access' you mean access to create the device?  That
sounds good.

thanks,
-serge
