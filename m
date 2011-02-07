From: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Subject: Re: [PATCH, v5 2/2] cgroups: introduce timer slack subsystem
Date: Mon, 7 Feb 2011 14:26:28 +0200
Message-ID: <20110207122628.GC11712__36260.4638831273$1297081712$gmane$org@shutemov.name>
References: <1297071962-11654-1-git-send-email-kirill@shutemov.name>
	<1297071962-11654-3-git-send-email-kirill@shutemov.name>
	<20110207100624.GB28911@balbir.in.ibm.com>
	<20110207105730.GA11852@shutemov.name>
	<20110207121430.GM27729@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110207121430.GM27729-SINUvgVNF2CyUtPGxGje5AC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Arjan van de Ven <arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Feb 07, 2011 at 05:44:30PM +0530, Balbir Singh wrote:
> * Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org> [2011-02-07 12:57:30]:
> 
> > On Mon, Feb 07, 2011 at 03:36:24PM +0530, Balbir Singh wrote:
> > > 2. Can there be an overlap in the ranges?
> > 
> > What overlap do you mean?
> > There is only one rule: parent's range should be wider then child's.
> 
> Between the children, can we have something like
> 
>         10-200
>         /    \
>        /      \
>       V        V
>    10-110    100-200

Yes, sure.

-- 
 Kirill A. Shutemov
