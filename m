From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/6] netns: add linux-vrf features via network namespaces
Date: Thu, 30 Oct 2008 10:03:04 -0500
Message-ID: <20081030150304.GC15099@us.ibm.com>
References: <4909B10A.8090403@thomson.net>
	<200810301538.08032.andreas.aaen@tietoenator.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <200810301538.08032.andreas.aaen-546VmZ+UeKYX2WXlbB3fKg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andreas B Aaen <andreas.aaen-546VmZ+UeKYX2WXlbB3fKg@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Andreas B Aaen (andreas.aaen-546VmZ+UeKYX2WXlbB3fKg@public.gmane.org):
> Hi,
> 
> On Thursday 30 October 2008 14:05, Vivien Chappelier wrote:
> >     The recently introduced network namespaces allow separate standalone
> > network stacks to coexist on the same machine. This is a very useful
> > functionality that we have been needing and using in our products for
> > some time, through the VRF ptchset (http://linux-vrf.sourceforge.net/).
> > The goal of the VRF patchset and network namespaces are very similar,
> > yet some features of the VRF are missing that these patches intend to
> > provide.
> 
> I have worked with a similar patchset. the goal was to be able to terminate 
> traffic from different IPv4 nets with possible overlapping IP addresses. You 
> should be able to communicate with all IPv4 nets from the same process.
> 
> >     The network namespaces are currently tied to a process, and
> > referenced by its pid. However, a networking stack has no particular
> > reason to be associated with any process and it should be possible to
> > use and setup additional networking stacks without the need to clone()
> 
> Right.
> 
> > or unshare(). The initial version of the "Coexist with the sysfs
> > limitations" patches by Benjamin Thery introduced the notion of a unique
> > network namespace identifier (nsid)  that is perfectly fit for the
> > purpose of referencing networking stacks independently of any process.
> > The first two patches of his set are therefore reused here to identify
> > networking stacks.
> 
> I have proposed such a global namespace before on this list, but no one seemed 
> interested.

Eric in particular is opposed to any "nsid" because it introduces yet
another namespace to worry about at checkpoint/restart.  A reasonable
concern.

There was quite a bit of talk at the containers mini-summit about
creating a minimal filesystem to represent the namespaces.  (See 
http://wiki.openvz.org/Containers/Mini-summit_2008_notes for the notes,
but they're not particularly helpful on their own).

Eric, if you have a moment, could you recap your proposal?

thanks,
-serge
