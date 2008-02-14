From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/4] The control group itself
Date: Thu, 14 Feb 2008 11:17:18 -0600
Message-ID: <20080214171718.GA11517@sergelap.austin.ibm.com>
References: <47AAFFF2.9030804@openvz.org> <47AB013B.8060502@openvz.org>
	<20080211173830.GA22160@sergelap.ibm.com>
	<47B174B2.5010500@openvz.org>
	<20080212172134.GA12177@sergelap.austin.ibm.com>
	<6599ad830802121817n7713fa85h51aedf4df74aa764@mail.gmail.com>
	<20080212204215.2eca689f.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080212204215.2eca689f.pj-sJ/iWh9BUns@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Paul Jackson (pj-sJ/iWh9BUns@public.gmane.org):
> Paul M wrote:
> > > Is there any
> > > way it would be ok to have cgroup_file_write() check for CAP_SYS_ADMIN?
> > 
> > Sure, we could have flags in the subsys object for this kind of thing
> > that let particular subsystems request this.
> 
> That sounds like it would work fine ... the cpuset subsystem would
> just not request this.

Cool I'll keep it in mind then - though really right now it seems like
it just amounts to slightly more complicated approach than just having
the subsystems do the check in _write...

thanks,
-serge
