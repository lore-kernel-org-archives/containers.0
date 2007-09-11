From: Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: pid namespace .text overhead
Date: Tue, 11 Sep 2007 08:36:08 -0700
Message-ID: <1189524968.17236.18.camel@localhost>
References: <46E59D2B.7030609@fr.ibm.com> <20070911020406.GA31721@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070911020406.GA31721-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 2007-09-10 at 19:04 -0700, sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> 
> Thats a good point.
> 
> We have been a bit liberal with "inline" given that lot of the code
> was
> going to affect the "fast-path" clone().
> 
> Should we shoot for a time/space trade-off or can we make some inlines
> conditional (i.e inline when not configured for say embedded linux) ? 

Can we make them switch somehow on -Os?  That's what the embedded guys
use.

-- Dave
