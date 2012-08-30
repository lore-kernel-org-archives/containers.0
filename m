From: Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [CRIU] Re: Error compiling CRtools-0.1..
Date: Thu, 30 Aug 2012 17:30:33 +0400
Message-ID: <20120830133033.GL21422@moon>
References: <604C0E70D2B64644B0BCE6939D9F7D0327A1C6@BGSMSX102.gar.corp.intel.com>
	<604C0E70D2B64644B0BCE6939D9F7D0327E011@BGSMSX102.gar.corp.intel.com>
	<20120830125557.GB8474@amd1> <20120830131058.GK21422@moon>
	<604C0E70D2B64644B0BCE6939D9F7D0327E623@BGSMSX102.gar.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <604C0E70D2B64644B0BCE6939D9F7D0327E623-yHIBzpp8AekFyVwBAnZdSLfspsVTdybXVpNB7YpNyf8@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Muralidhar, Rajeev D" <rajeev.d.muralidhar-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: "criu-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org" <criu-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Aug 30, 2012 at 01:16:27PM +0000, Muralidhar, Rajeev D wrote:
> Hi Cyril
> 
> Yes, that is the branch I am running - 3.6-rc1. And I have all the config options turned
> on in the kernel as documented in the crui.org website. 
> 
> The errors I am seeing seem to be coming from netlink. What are the dependencies on netlink packages?
> Error seems to be suggesting that it cant stat any of the netlink sockets.

Could you please clarify, you're running exactly version 0.1 or current git
snapshot from crtools repo? (Don't think it's problem with netlink, there
is something else failing).

	Cyrill
