From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/4] The control group itself
Date: Thu, 14 Feb 2008 11:18:57 -0600
Message-ID: <20080214171857.GB11517@sergelap.austin.ibm.com>
References: <47AAFFF2.9030804@openvz.org> <47AB013B.8060502@openvz.org>
	<20080211173830.GA22160@sergelap.ibm.com>
	<47B174B2.5010500@openvz.org>
	<20080212172134.GA12177@sergelap.austin.ibm.com>
	<20080212203215.fb636900.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080212203215.fb636900.pj-sJ/iWh9BUns@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Paul Jackson (pj-sJ/iWh9BUns@public.gmane.org):
> Serge wrote:
> > Paul (actually both Menage and Jackson :) do you have an opinion on
> > this?  Are there sites which eg do 'chown -R some_user_id /cgroup/cpusets/'
> > to have some non-root user be able to dole out cpusets?  Is there any
> > way it would be ok to have cgroup_file_write() check for CAP_SYS_ADMIN?
> 
> I don't know what my users actually do here ... I'm a couple layers
> removed from that reality.  But certainly I've recommended that they
> sometimes do things like having the batch scheduler chown the files
> of each jobs cpuset to the uid of the user running that job, so that
> the job can manipulate its own cpuset allocate resources in finer
> detail.
> 
> One of the more elaborate ways of doing this nests a pair of cpusets,
> with the parent owned by the batch scheduler confining the child
> owned by the individual job.  The job can actually do things like
> write its own cpus and mems files, but is confined by the parent
> cpuset to only specify cpus and mems assigned to that job.
> 
> As to how this affects your question ... I'm not sure.  However I
> suspect that an added requirement for CAP_SYS_ADMIN would cause
> breakage and not be a good idea.

Yeah, I guess a more general mechanism to couple a user namespace's
connection to a mount is the right way to go.  If we can just specify
that root in this namespace is not root in that namespace (or any other
userid we've chowned the files to), we've got what we need.

thanks,
-serge
