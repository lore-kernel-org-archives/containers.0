From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [BUG][cryo] Create file on restart ?
Date: Wed, 16 Jul 2008 21:21:34 -0500
Message-ID: <20080717022134.GB21726@us.ibm.com>
References: <20080716185027.GA1335@us.ibm.com>
	<20080716192604.GA27454@us.ibm.com>
	<20080716204529.GA4278@us.ibm.com>
	<20080716205737.GA2082@us.ibm.com>
	<20080716212609.GB4278@us.ibm.com>
	<1216247460.4844.177.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1216247460.4844.177.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> 
> On Wed, 2008-07-16 at 14:26 -0700, sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> > Serge E. Hallyn [serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
> > | Quoting sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org (sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> > | > Serge E. Hallyn [serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
> > | > | Quoting sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org (sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> > | > | > 
> > | > | > cryo does not (cannot ?) recreate files if the application created
> > | > | 
> > | > | I think that's for the best.
> > | > | 
> > | > | Don't you?
> > | > 
> > | > I can understand that configuration or data files should exist, but
> > | > not sure about temporary or log files that an application created
> > | > upon start-up and expects to be present. Should the admin find
> > | > out about them and create them by hand before restart ?
> > | 
> > | I think the admin should have set the destination environment such that
> > | the task is restarted in the same network fs in the same directory, with
> > | no files having been deleted.
> 
> [Assuming Serge meant: s/network fs/network, fs,/]

Well no I meant a network filesystem - at least if you're migrating apps
around a cluster.

> > or new files created ? For instance if the application was checkpointed
> > before it created a temporary file with O_EXCL flag, that temporary
> > file must not exist when restarting ?
> 
> 	I think that's not a problem given my assumptions above. The filesystem
> that the application restarts in would be the same because the admin
> should have set up the restart environment as Serge suggested. The admin
> can't rely on restart in an alternate environment. However, given
> knowledge of the application and environment, using an alternate
> environment may be a risk the admin is willing to take.

Yup.  But Suka is right that in the case of the checkpointed app
continuing to run for a bit before being killed and restarted, it could
get out of whack with respect to the file system.

> > | Am I wrong?
> > 
> > So we take a snapshot of the FS and checkpoint the application. Do they
> > need to be atomic ?
> 
> 	If all the applications in a container are frozen then I think we can
> get fs snapshots consistent with checkpointed applications.
> Otherwise, yes, I think we'd be gambling that the checkpointed
> application isn't interacting with another, running, application via an
> intermittently-shared file.

What fun :)

I wonder whether the experience of users of c/r on sgi and cray could
teach us anything here.

-serge
