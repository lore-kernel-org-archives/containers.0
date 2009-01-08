From: Benny Amorsen <benny+usenet-sjWZyPj6pFx/SzgSGea1oA@public.gmane.org>
Subject: Re: [RFC][PATCH] IP address restricting cgroup subsystem
Date: Thu, 08 Jan 2009 13:43:15 +0100
Message-ID: <m34p0at1cs.fsf@ursa.amorsen.dk>
References: <20090106230554.GB25228@eskarina.localdomain.pl>
	<20090107180752.GA19153@us.ibm.com>
	<20090107191536.GA15159@megiteam.pl>
	<20090107193234.GA22625@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090107193234.GA22625-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message of
	"Wed\, 7 Jan 2009 13\:32\:34 -0600")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <public-serue-r/Jw6+rmf7HQT0dZR+AlfA-z5DuStaUktnZ+VzJOa5vwg@public.gmane.org>
Cc: Grzegorz Nosek <public-root-AfQBxy1nhrQ00sYp1HPQUA-z5DuStaUktnZ+VzJOa5vwg@public.gmane.org>, public-containers-qjLDD68F18O7TbgM5vRIOg-z5DuStaUktnZ+VzJOa5vwg@public.gmane.org
List-Id: containers.vger.kernel.org



"Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA-XMD5yJDbdMReXY1tMh2IBg@public.gmane.org>
writes:

> Does anyone else (Eric? Pavel?) have experience with hundreds
> or thousands of network namespaces?

Hundreds aren't a problem with OpenVZ (I do that in production) and
the vanilla kernel namespaces shouldn't be heavier. I don't think
performance is a good argument for the patch.

However, I do see the appeal of patch anyway. It would be tempting to
use cgroups inside a network namespace for administrative reasons,
like Grzegorz Nosek proposed. I am not sure if you can create name
spaces with the semantics he proposed:

 - INADDR_LOOPBACK is explicitly allowed (a special case)
 - INADDR_ANY is remapped to _the_ IP address
 - _the_ IP address is passed through unharmed
 - everything else causes -EPERM

If you can get those semantics (or something close) already, then the
patch isn't useful.


/Benny
