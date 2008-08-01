From: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [Devel] [RFC][PATCH 0/2] CR: save/restore a single, simple task
Date: Fri, 1 Aug 2008 09:28:20 +0400
Message-ID: <200808010928.21220.major@openvz.org>
References: <Pine.LNX.4.64.0807292306570.9868@takamine.ncl.cs.columbia.edu>
	<200807310511.11648.major@openvz.org>
	<20080731212810.GB7858@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080731212810.GB7858-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Friday 01 August 2008 01:28 Serge E. Hallyn wrote:
> Quoting Andrey Mirkin (major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org):
> > Hello Oren,
> >
> > That is great, that you have proposed your version of
> > checkpointing/restart. In a few days I will send a patchset with OpenVZ
> > checkpointing/restart. So, we will be able to compare our approaches and
> > take the best parts from both.
>
> Excellent, looking forward to it!  Are you going to stick to the same
> limitations as Oren did?  (I think it would be best)
Yes, I'll send patches which are able to checkpoint/restart just a single, 
simple process.

Andrey
