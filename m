From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: containers development plans (July 20 version)
Date: Mon, 23 Jul 2007 09:24:18 -0500
Message-ID: <20070723142418.GD22936@sergelap.austin.ibm.com>
References: <20070720173615.GA25167@vino.hallyn.com>
	<6599ad830707201702g1acae7ddt16a502984baa64cc@mail.gmail.com>
	<m1y7ha1sg2.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m1y7ha1sg2.fsf-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
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
Cc: ckrm-tech-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, xemul-3ImXcnM4P+0@public.gmane.org, cpw-sJ/iWh9BUns@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, pj-sJ/iWh9BUns@public.gmane.org, rohitseth-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> writes:
> 
> > On 7/20/07, Serge E. Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> wrote:
> >>         4. task containers functionality
> >>                 base features
> >>                         virtualized continerfs mounts
> >>                                 to support vserver mgmnt of sub-containers
> >>                         locking cleanup
> >>                         control file API simplification
> >>                         control file prefixing with subsystem name
> >
> > This last point was actually in the set of patches that I sent to akpm
> > today - probably it was too small an item to be worth including in
> > this list.
> >
> >> Stakeholders:
> >>         Eric Biederman
> >>                 everything
> >>         google
> >>                 task containers
> >
> > If the checkpoint/restart code is expected to evolve into a workable
> > live migration system, we'd be interested in that too.
> 
> At least the support for live migration should be there.

Yeah, sorry, I kind of take it for granted that when i say 'c/r' i would
want live migration, but i shouldn't.  Will spell that out.

thanks,
-serge
