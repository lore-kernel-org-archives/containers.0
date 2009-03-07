From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: Re: [v2][PATCH 2/5] Parse mount options just once and copy them to
	super block
Date: Sat, 7 Mar 2009 09:31:29 -0800
Message-ID: <20090307173129.GA29293@us.ibm.com>
References: <20090204043516.GB25963@us.ibm.com> <20090204043705.GB26202@us.ibm.com> <20090205001010.GC17354@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755921AbZCGRdO@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090205001010.GC17354@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, hpa@zytor.com, hch@lst.de, sukadev@us.ibm.com, Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Sorry, I had not responded to this:

Serge E. Hallyn [serue@us.ibm.com] wrote:
| > -	if (new)
| > -		return new_pts_mount(fs_type, flags, data, mnt);
| > +	memset(&opts, 0, sizeof(opts)); 
| > +	if (data) {
| > +		error = parse_mount_options(data, PARSE_MOUNT, &opts);
| 
| Is there any reason to keep the PARSE_MOUNT argument to
| parse_mount_options?

Yes parse_mount_options() needs to know whether it is a MOUNT or 
REMOUNT operation - MOUNT operation should clear 'newinstance' to
default before parsing, but REMOUNT should not.
