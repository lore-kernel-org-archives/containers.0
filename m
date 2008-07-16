From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: Re: [BUG][cryo] Create file on restart ?
Date: Wed, 16 Jul 2008 16:20:24 -0700
Message-ID: <20080716232024.GC4278@us.ibm.com>
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

| 	If all the applications in a container are frozen then I think we can
| get fs snapshots consistent with checkpointed applications.

I agree in general, but cryo currently takes a checkpoint and the
application resumes, which means the application could create the
temp file.  So, cryo should not resume the application until the
FS snapshot is taken too I guess.

| Otherwise, yes, I think we'd be gambling that the checkpointed
| application isn't interacting with another, running, application via an
| intermittently-shared file.

Yes.
