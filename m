From: Greg KH <greg@kroah.com>
Subject: Re: [PATCHSET 3/4] sysfs: divorce sysfs from kobject and driver
	model
Date: Tue, 9 Oct 2007 15:53:06 -0700
Message-ID: <20071009225306.GG21228@kroah.com>
References: <11902755392688-git-send-email-htejun@gmail.com> <20070925221736.GA3566@kroah.com> <46FB956B.8000205@gmail.com> <m1zlz7hpvn.fsf_-_@ebiederm.dsl.xmission.com> <20071005062302.GB16914@kroah.com> <m1myuxloiz.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756720AbXJIW7q@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1myuxloiz.fsf@ebiederm.dsl.xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Tejun Heo <htejun@gmail.com>, cornelia.huck@de.ibm.com, stern@rowland.harvard.edu, kay.sievers@vrfy.org, linux-kernel@vger.kernel.org, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

On Fri, Oct 05, 2007 at 06:44:04AM -0600, Eric W. Biederman wrote:
> Greg KH <greg@kroah.com> writes:
> 
> > I would be interested in seeing what your patches look like.
> 
> Sure. 
> 
> > I don't
> > think that we should take any more sysfs changes for 2.6.24 as we do
> > have a lot of them right now, and I don't think that Tejun and I agree
> > on the future direction of the outstanding ones just yet.
> 
> Sounds reasonable.
> 
> > But I don't think that your multiple-mount patches could make it into
> > .24, unless .23 is still weeks away.
> 
> Well I have posted them all earlier.  At this point I it makes most
> sense to wait until after the big merge happen and every rebases on
> top of that.  Then everyone will have network namespace support and
> it is easier to look through all of the patches.  Especially since
> it looks like the merge window will open any day now.
> 
> I will quickly recap the essence of what I am looking at:
> On directories of interest I tag all of their directory
> entries with which namespace they belong to.  On a mount
> of sysfs I remember which namespace we were in when we
> mounted sysfs.  The I filter readdir and lookup based upon
> the namespace I captured at mount time.  I do my best
> to generalize it so that the logic can work for different
> namespaces.

Ok, I have no objection to that.  Let's wait for 2.6.24 to settle down
:)

thanks,

greg k-h
