From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [TESTING] Device whitelist on cgroups
Date: Tue, 26 Aug 2008 11:00:03 -0500
Message-ID: <20080826160003.GA21827@us.ibm.com>
References: <1219699261.5434.22.camel@subratamodak.linux.ibm.com>
	<20080826133358.GB12266@us.ibm.com> <48B40FC7.2000900@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <48B40FC7.2000900-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: ltp-list <ltp-list-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Veerendra Chandrappa <vechandr-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Serge Hallyn <serue-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Subrata Modak <subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Pavel Emelyanov (xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org):
> Serge E. Hallyn wrote:
> > Quoting Subrata Modak (subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> >> Serge,
> >>
> >> I have another doubt. Are we also having the plan(s) to add testcases
> >> for testing this new feature (Device whitelist on cgroups) added in
> >> 2.6.26 under the DEVICE NAMESPACE category !!
> >>
> >> Regards--
> >> Subrata
> > 
> > That's something I expect Veerendra would do next year.  (Veerendra,
> > if you have time this year, please let me know).
> > 
> > It also seems likely that the openvz folks, who are using this,
> > have some testcases they could share.  Pavel?
> 
> We have and we could share them, but unfortunately their 
> *implementation* is completely useless without the whole 
> testing infrastructure we use (which it turn is too heavy
> and too Virtuozzo-specific to be shared).
> 
> All I can is provide a single testcase we perform: set some
> permissions and check that the allowed devices are allowed
> and not allowed are not allowed ;)

Ok, thanks, Pavel.  Sounds like starting from scratch would be
the simplest thing here.

-serge
