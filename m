From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 02/10] cr_tests: fileio: Fix do_child(i) call
Date: Mon, 15 Mar 2010 23:04:10 -0700
Message-ID: <20100316060410.GD3037@count0.beaverton.ibm.com>
References: <69be886209c375c99b00b0745c1b0efdf334dcc3.1268694050.git.matthltc@us.ibm.com>
	<39d445e0d6bb5b1420daf672aa48ebabf8648ffe.1268694050.git.matthltc@us.ibm.com>
	<1268695929.4397.134.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1268695929.4397.134.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Mar 15, 2010 at 06:32:09PM -0500, Nathan Lynch wrote:
> On Mon, 2010-03-15 at 16:00 -0700, Matt Helsley wrote:
> > do_child() does not have an i parameter yet main calls do_child(i).
> > Clearly it's unused so just remove it.
> > 
> > Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > ---
> >  fileio/fsetown1.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/fileio/fsetown1.c b/fileio/fsetown1.c
> > index a30e870..57f9bb6 100644
> > --- a/fileio/fsetown1.c
> > +++ b/fileio/fsetown1.c
> > @@ -226,7 +226,7 @@ int main(int argc, char *argv[])
> >  	 */
> >  	pid = fork();
> >  	if (pid == 0)
> > -		do_child(i);
> > +		do_child();
> 
> Change the definition of do_child from
> 
> void do_child()
> 
> to 
> 
> void do_child(void)
> 
> please?

Sure. I'll attach another copy of the patch with the change in a reply
to this.

> wait_for_child and setup_test_data need the same treatment.

OK.

Thanks!

Cheers,
	-Matt Helsley
